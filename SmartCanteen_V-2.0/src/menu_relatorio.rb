=begin
3. Etapa 3: Adição de novos relatórios ao nosso sistema
3.1.1. Relatório do total de atendimentos realizados por cada atendente em um dia
específico;
3.1.2. Relatório do total de valor vendido por cada atendente em um dia específico;
=end
require_relative '../bd/dbConn'
require_relative 'validacao'
require_relative 'utils'
require 'date'

def listarClientes()
  begin
    clientes = DB.execute("SELECT * FROM clientes")

    clientes.each_slice(3) do |grupo|
      grupo.each do |cliente|
        printf("| ID: %-2s - %-20s ", cliente['id'], cliente['nome'][0..19])
      end
      puts "|" 
    end

  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end

def listarProdutos()
  begin
    produtos = DB.execute "SELECT * FROM produtos"

    produtos.each_slice(3) do |grupo|
      grupo.each do |produto|
        printf("| ID: %-2s - %-25s ", produto['id'], produto['nome'][0..24])  
      end
      puts "|" 
    end

  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end

def listarVendas()
  query = <<-SQL
    SELECT 
      v.id_venda, v.data_da_compra, 
      c.nome AS cliente,
      p.nome AS produto,
      f.nome AS vendedor,
      crg.nome_cargo AS cargo,
      iv.quantidade, p.preco, 
      (iv.quantidade * p.preco) AS subtotal
    FROM vendas v 
    JOIN clientes c ON v.cliente_ID = c.id
    JOIN funcionarios f ON v.id_vendedor = f.id
    JOIN cargos crg ON f.cargos_idcargos = crg.idcargos
    JOIN itens_da_venda iv ON v.id_venda = iv.id_venda
    JOIN produtos p ON iv.id_produto = p.id
    ORDER BY v.id_venda;
  SQL

  begin
    vendas = DB.execute(query)
    if vendas.empty?
      puts"Nenhua venda registrada no sistema"
    end

    puts "RELATÓRIO DE VENDAS".center(50)
    sep(:duplo)

    #Agrupa todos os resultados pelo ID da venda
    vendas_agrupadas = vendas.group_by {|linha| linha['id_venda']}

    vendas_agrupadas.each do |id_venda, itens|
      #pega as informações gerais da primeira linha (já que são iguais oara todos os itens da venda)
      venda_info = itens.first

      #calcula o total da venda somando os subtotais de cada item
      total_venda = itens.sum { |i| i['subtotal'].to_f}

      sep(:estrela)
      puts "ID: #{id_venda} | Data: #{venda_info['data_da_compra']} | Cliente: #{venda_info['cliente']}"
      puts "Vendedor: #{venda_info['vendedor']} (#{venda_info['cargo']})"
      puts "TOTAL DA VENDA: R$ #{'%.2f' % total_venda}"
      puts "PRODUTOS:"

      #loop apenas nos itens da venda específica
      itens.each do |item|
        puts "  -> #{item['produto']} | Qtd: #{item['quantidade']} | Preço: R$ #{item['preco']} | Subtotal: R$ #{item['subtotal']}"
      end
    end
    sep(:simples)

  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end 

def validarData(data)
  while true
    if data =~ /^\d{2}-\d{2}-\d{4}$/
      dia, mes, ano = data.split('-').map(&:to_i)
      begin
        data_valida = Date.new(ano, mes, dia)
        return data_valida
      rescue ArgumentError
        puts "Data inválida. Por favor, insira uma data válida no formato DD-MM-AAAA:"
      end
    else
      puts "Formato inválido. Por favor, insira a data no formato DD-MM-AAAA:"
      data = gets.chomp
    end
  end
end

def totalVendasDia(data_valida)
  begin
    data_inicio = data_valida.strftime("%Y-%m-%d 00:00:00")
    data_fim    = data_valida.strftime("%Y-%m-%d 23:59:59")

    query = <<-SQL
      SELECT 
        v.id_venda,
        v.data_da_compra,
        c.nome AS cliente,
        p.nome AS produto,
        iv.quantidade,
        p.preco,
        (iv.quantidade * p.preco) AS subtotal
      FROM vendas v
      JOIN clientes c ON v.cliente_id = c.id
      JOIN itens_da_venda iv ON v.id_venda = iv.id_venda
      JOIN produtos p ON iv.id_produto = p.id
      WHERE v.data_da_compra BETWEEN ? AND ?
      ORDER BY v.id_venda
    SQL

    vendas = DB.execute(query, [data_inicio, data_fim])

    if vendas.empty?
      puts "Nenhuma venda registrada em #{data_valida.strftime('%d/%m/%Y')}"
      return
    end

    puts "RELATÓRIO DE VENDAS DO DIA #{data_valida.strftime('%d/%m/%Y')}".center(60)
    sep(:simples)

    vendas_agrupadas = vendas.group_by { |linha| linha['id_venda'] }
    quantidade_vendas = vendas_agrupadas.size

    puts "Quantidade de vendas no dia: #{quantidade_vendas}"
    sep(:simples)

    total_dia = 0

    vendas_agrupadas.each do |id_venda, itens|
      venda_info = itens.first
      total_venda = itens.sum { |i| i['subtotal'].to_f }
      total_dia += total_venda

      sep(:estrela)
      puts "ID: #{id_venda} | Data: #{venda_info['data_da_compra']} | Cliente: #{venda_info['cliente']}"
      puts "TOTAL DA VENDA: R$ #{'%.2f' % total_venda}"
      puts "PRODUTOS:"

      itens.each do |item|
        puts "  -> #{item['produto']} | Qtd: #{item['quantidade']} | Preço: R$ #{'%.2f' % item['preco']} | Subtotal: R$ #{'%.2f' % item['subtotal']}"
      end
    end

    sep(:simples)
    puts "VALOR TOTAL FATURADO NO DIA: R$ #{'%.2f' % total_dia}"
    sep(:simples)

  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end

def produtoMaisVendido
  begin
    produto = DB.get_first_row <<-SQL
      SELECT 
        p.id AS id_produto,
        p.nome AS nome,
        SUM(iv.quantidade) AS total_vendido
      FROM itens_da_venda iv
      JOIN produtos p ON iv.id_produto = p.id
      GROUP BY p.id, p.nome
      ORDER BY total_vendido DESC
      LIMIT 1
    SQL

    if produto
      sep(:simples)
      puts "Produto mais vendido:"
      puts "ID: #{produto['id_produto']}"
      puts "Nome: #{produto['nome']}"
      puts "Quantidade vendida: #{produto['total_vendido']}"
      sep(:simples)
    else
      sep(:simples)
      puts "Nenhuma venda registrada."
      sep(:simples)
    end

  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end

def atendimentosPorFuncionarioDia(data)
    query = <<-SQL
      SELECT f.nome, c.nome_cargo, COUNT(v.id_venda) as qtd
      FROM vendas v JOIN funcionarios f ON v.id_vendedor = f.id
      JOIN cargos c ON f.cargos_idcargos = c.idcargos
      WHERE v.data_da_compra BETWEEN ? AND ? GROUP BY f.id ORDER BY qtd DESC
    SQL
    
    res = DB.execute(query, [data.strftime("%Y-%m-%d 00:00:00"), data.strftime("%Y-%m-%d 23:59:59")])
    puts "ATENDIMENTOS EM #{data.strftime('%d/%m/%Y')}".center(50); sep(:traco)
    res.each { |r| printf("| %-20s | %-12s | %3d vendas |\n", r['nome'], r['nome_cargo'], r['qtd']) }
end

def valorVendidoPorFuncionarioDia(data)
    query = <<-SQL
      SELECT f.nome, SUM(iv.quantidade * p.preco) as total
      FROM vendas v JOIN itens_da_venda iv ON v.id_venda = iv.id_venda
      JOIN produtos p ON iv.id_produto = p.id JOIN funcionarios f ON v.id_vendedor = f.id
      WHERE v.data_da_compra BETWEEN ? AND ? GROUP BY f.id ORDER BY total DESC
    SQL

    res = DB.execute(query, [data.strftime("%Y-%m-%d 00:00:00"), data.strftime("%Y-%m-%d 23:59:59")])
    puts "FATURAMENTO POR ATENDENTE - #{data.strftime('%d/%m/%Y')}".center(50); sep(:traco)
    res.each { |r| printf("| %-25s | R$ %9.2f |\n", r['nome'], r['total']) }
end