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

  resultado = @db.execute("INSERT INTO vendas (cliente_ID) VALUES (?) RETURNING id_venda", [clientSelecionado])
  idVenda = resultado[0]['id_venda']
  
  addProdutos = "s"
  while addProdutos != "n"
    listarProdutos()
    print "Selecione o produto pelo ID: "
    produtoSelecionado = gets.chomp.to_i
    print "Digite a quantidade do produto selecionado: "
    qte = gets.chomp.to_i

    @db.execute("INSERT INTO itens_da_venda (id_produto, id_venda, quantidade) VALUES (?, ?, ?)", [produtoSelecionado, idVenda, qte])
    print "Deseja adicionar mais produtos a venda? (s/n): "
    addProdutos = gets.strip[0].downcase
    while addProdutos != "s" && addProdutos != "n"
      print "Opção inválida. Deseja adicionar mais produtos a venda? (s/n): "
      addProdutos = gets.strip[0].downcase
    end
  end
end

