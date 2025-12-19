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
  begin
    vendas = @db.execute (
    "
    SELECT v.id_venda, v.data_da_compra, c.nome AS cliente, p.nome AS produto,
      iv.quantidade, p.preco, (iv.quantidade * p.preco) AS subtotal
      FROM vendas v 
      JOIN clientes c ON v.cliente_ID = c.id
      JOIN itens_da_venda iv ON v.id_venda = iv.id_venda
      JOIN produtos p ON iv.id_produto = p.id
      GROUP BY v.id_venda;
     "
    )
    if vendas.empty?
      puts"Nenhua venda registrada no sistema"
    end

    puts "RELATÓRIO DE VENDAS".center(50)
    sep(:duplo)

    vendas.each do |linha|
      id = linha['id_venda'] 
      data = linha['data_da_compra']
      cliente = linha['cliente']
      produto = linha['']
      qtd = linha['quantidade']
      preco = linha['preco']
      subtotal = linha['subtotal']

      puts linha
      puts "ID: #{id} | Data: #{data} | Cliente: #{cliente}"
      puts "-> Produto: #{produto} | Qtd: #{qtd} | Unit: R$#{preco} | Total Item: R$#{'%.2f' % subtotal}"
      sep(:simples)
    end
    
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
