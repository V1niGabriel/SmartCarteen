require_relative '../bd/dbConn'
require_relative 'menu_relatorio'


def cadastrarProduto()
  print "Digite o nome do produto: "
  nome = gets.chomp
  print "Digite o tipo do produto: "
  tipo = gets.chomp
  print "Digite o preço do produto: "
  preco = gets.chomp.to_f

  @db.execute("INSERT INTO produtos (nome, tipo, preco) VALUES (?, ?, ?)", [nome, tipo, preco])
  puts "Produto cadastrado com sucesso!"
end

def cadastrarCliente()
  print "Digite o nome do cliente: "
  nome = gets.chomp

  @db.execute("INSERT INTO clientes (nome) VALUES (?)", [nome])
  puts "Cliente cadastrado com sucesso!"
end

def registrarVenda()
  listarClientes()
  print "Selecione o cliente pelo ID: "
  clientSelecionado = gets.chomp
  
  addProdutos = 1
  while addProdutos != 0
    listarProdutos()
    print "Selecione o cliente pelo ID: "

end

