require_relative '../bd/dbConn'
require_relative 'validacao.rb'

def listarClientes()
  begin
    clientes = @db.execute("SELECT * FROM clientes")

    clientes.each do |cliente|
      puts "id: #{cliente['id']} - Nome: #{cliente['nome']}"
    end

  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  rescue NoMethodError => e
    puts "Falha de lógica: #{e.message}"
  rescue  SQLite3::SQLException => e 
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  end
end

def listarProdutos()
  begin
    produtos = @db.execute "SELECT * FROM produtos"

    produtos.each do |produto|
      puts "id: #{produto['id']} - Nome: #{produto['nome']} - Preço: R$#{'%.2f' % produto['preco']}"
    end

  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  rescue NoMethodError => e
    puts "Falha de lógica: #{e.message}"
  rescue  SQLite3::SQLException => e 
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
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

  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  rescue NoMethodError => e
    puts "Falha de lógica: #{e.message}"
  rescue  SQLite3::SQLException => e 
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  end
end

def totalVendasDia()
end