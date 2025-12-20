require_relative '../bd/dbConn'
require_relative 'validacao'
require_relative 'utils'
require 'date'

def listarClientes()
  begin
    clientes = @db.execute("SELECT * FROM clientes")

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
    produtos = @db.execute "SELECT * FROM produtos"

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
    SELECT v.id_venda, v.data_da_compra, c.nome AS cliente, p.nome AS produto,
      iv.quantidade, p.preco, (iv.quantidade * p.preco) AS subtotal
    FROM vendas v 
    JOIN clientes c ON v.cliente_ID = c.id
    JOIN itens_da_venda iv ON v.id_venda = iv.id_venda
    JOIN produtos p ON iv.id_produto = p.id
    ORDER BY v.id_venda;
  SQL

  begin
    vendas = @db.execute (query)
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

def totalVendasDia(data_valida) #IAN DISSE QUE VAI FAZER ENTÃO FICA PRA ELE FAZER
  begin
    data_inicio = data_valida.strftime("%Y-%m-%d 00:00:00")
    data_fim = data_valida.strftime("%Y-%m-%d 23:59:59")
    vendas = @db.execute("SELECT V.id_venda, C.nome AS cliente_nome, P.nome AS produto_nome 
                          FROM vendas V 
                          JOIN clientes C ON V.cliente_ID = C.id 
                          JOIN produtos P ON V.id_venda = P.id 
                          WHERE V.data_da_compra BETWEEN ? AND ?", [data_inicio, data_fim])
    total = 0
    vendas.each do |venda|
      total += 1
    end
    puts "Total de vendas no dia #{data_valida}: #{total}"
  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end

def produtoMaisVendido
  begin
    produto = @db.get_first_row <<-SQL
      SELECT 
        produtos.nome AS nome,
        SUM(itens_da_venda.quantidade) AS total_vendido
      FROM itens_da_venda
      JOIN produtos ON itens_da_venda.id_produto = produtos.id
      GROUP BY itens_da_venda.id_produto
      ORDER BY total_vendido DESC
      LIMIT 1
    SQL

    if produto
      sep(:simples)
      puts "Produto mais vendido:"
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
