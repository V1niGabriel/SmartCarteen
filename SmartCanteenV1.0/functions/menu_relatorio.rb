require_relative '../bd/dbConn'

def listarClientes()
  clientes = @db.execute("SELECT * FROM clientes")

  clientes.each do |cliente|
    puts "id: #{cliente['id']} - Nome: #{cliente['nome']}"
  end
end

def listarProdutos()
  produtos = @db.execute "SELECT * FROM produtos"

  produtos.each do |produto|
    puts "id: #{produto['id']} - Nome: #{produto['nome']} - Preço: R$#{'%.2f' % produto['preco']}"
  end
end

def listarVendas()
  vendas = @db.execute <<-SQL
    SELECT vendas.id, clientes.nome AS cliente_nome, produtos.nome AS produto_nome, vendas.data_hora
    FROM vendas
    JOIN clientes ON vendas.cliente_id = clientes.id
    JOIN produtos ON vendas.produto_id = produtos.id
  SQL

  vendas.each do |venda|
    puts "id: #{venda['id']} - Cliente: #{venda['cliente_nome']} - Produto: #{venda['produto_nome']} - Data/Hora: #{venda['data_hora']}"
  end
end

def totalVendasDia()
end