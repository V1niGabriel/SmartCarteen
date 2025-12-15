require_relative '../bd/dbConn'
require_relative 'validacao'
require_relative 'utils'

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
  rescue NoMethodError => e
    puts "Falha de lógica: #{e.message}"
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
  rescue NoMethodError => e
    puts "Falha de lógica: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end

def listarVendas()
  begin
    vendas = @db.execute <<-SQL
    SELECT vendas.id, clientes.nome AS cliente_nome, produtos.nome AS produto_nome, vendas.data_hora
    FROM vendas
    JOIN clientes ON vendas.cliente_id = clientes.id
    JOIN produtos ON vendas.produto_id = produtos.id
  SQL

  vendas.each do |venda|
    puts "id: #{venda['id']} - Cliente: #{venda['cliente_nome']} - Produto: #{venda['produto_nome']} - Data/Hora: #{venda['data_hora']}"
  end

  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue NoMethodError => e
    puts "Falha de lógica: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end

def totalVendasDia() #IAN DISSE QUE VAI FAZER ENTÃO FICA PRA ELE FAZER
end

def produtoMaisVendido 
  begin
    @db.results_as_hash = true
    produto = @db.get_first_row <<-SQL
      SELECT produtos.nome AS nome, COUNT(vendas.produto_id) AS total_vendas
      FROM vendas
      JOIN produtos ON vendas.produto_id = produtos.id
      GROUP BY vendas.produto_id
      ORDER BY total_vendas DESC
      LIMIT 1
    SQL
    if produto
      puts "Produto mais vendido: #{produto['nome']} com #{produto['total_vendas']} vendas."
    else
      puts "Nenhuma venda registrada."
    end

  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue NoMethodError => e
    puts "Falha de lógica: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
end