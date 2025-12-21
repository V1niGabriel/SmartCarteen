require_relative 'menu_relatorio'


def cadastrarProduto()
  sep(:mais)
  begin
    print "Digite o nome do produto: "
    nome = gets.chomp
    sep(:simples)
    print "Digite o tipo do produto: "
    tipo = gets.chomp
    sep(:simples)
    print "Digite o preço do produto: "
    preco = gets.chomp.to_f
    sep(:simples)

    @db.execute("INSERT INTO produtos (nome, tipo, preco) VALUES (?, ?, ?)", [nome, tipo, preco])
      puts "Produto cadastrado com sucesso!"

  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
  sep(:mais)
end

def cadastrarCliente()
  sep(:mais)
  begin
     print "Digite o nome do cliente: "
    nome = gets.chomp
    sep(:simples)

    @db.execute("INSERT INTO clientes (nome) VALUES (?)", [nome])
    puts "Cliente cadastrado com sucesso!"

  rescue SQLite3::BusyException
    puts "Erro DB 501 - DB Ocupado: O arquivo está travado"
  rescue SQLite3::SQLException => e
    puts "Erro DB 500 - Erro SQL: #{e.message}"
  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
  sep(:mais)
end

def registrarVenda()
  # Verifica se há produtos e clientes cadastrados e retorna se algum estiver vazio
  if tabela_vazia("produtos")
    puts "Nenhum produto cadastrado. Cadastre um produto antes de registrar uma venda."
    sep(:mais)
    return
  end
  if tabela_vazia("clientes")
    puts "Nenhum cliente cadastrado. Cadastre um cliente antes de registrar uma venda."
    sep(:mais)
    return
  end

  sep(:traco)
  listarClientes()
  sep(:traco)
  
  # Verifica se o cliente existe
  clientSelecionado = nil
  loop do 
    print "Selecione o cliente pelo ID: "
    clientSelecionado = gets.chomp.to_i
    cliente_existe = verifica_registro_existe("clientes", clientSelecionado)
    
    cliente_existe ? break : puts("ID inválido.")
  end
  sep(:simples)

  carrinho = []
  sep(:traco)
  listarProdutos()
  sep(:traco)
  
  # Registro dos produtos da venda
  loop do
    # loop para verificar se o produto existe
    produtoSelecionado = nil
    loop do
      print "Selecione o produto pelo ID: "
      produtoSelecionado = gets.chomp.to_i
      produto_existe = verifica_registro_existe("produtos", produtoSelecionado)

      produto_existe ? break : puts("ID inválido.")
    end
    sep(:simples)
    
    # Solicita a quantidade do produto
    print "Digite a quantidade do produto selecionado: "
    qte = gets.chomp.to_i
    sep(:simples)

    # Adiciona o produto e a quantidade ao carrinho
    carrinho << {id: produtoSelecionado, quantidade: qte}

    print "Deseja adicionar mais produtos? (s/n): "
    decisao = gets.strip[0].downcase

    # Valida a decisão do usuário
    until ['s', 'n'].include?(decisao)
      print "Opção inválida. Digite 's' para continuar ou 'n' para sair: "
      decisao = gets.strip[0].downcase
    end
    sep(:simples)

    # Sai do loop se o usuário não quiser adicionar mais produtos
    break if decisao == 'n'
  end

  # Grava a venda e os itens da venda no banco de dados
  begin
    # Caso ocorra algum erro, nada será gravado no banco
    @db.transaction do 
      # Insere a venda na tabela vendas
      @db.execute("INSERT INTO vendas (cliente_ID) VALUES (?)", [clientSelecionado])
      id_venda = @db.last_insert_row_id 

      # Para cada item no carrinho, insere na tabela itens_da_venda
      carrinho.each do |item|
        @db.execute(
          "INSERT INTO itens_da_venda (id_produto, id_venda, quantidade) VALUES (?, ?, ?)",
          [item[:id], id_venda, item[:quantidade]]
        )
      end
    end 
    puts "Venda registrada com sucesso!"
  rescue SQLite3::Exception => e
    puts "Erro crítico ao salvar a venda. Nada foi gravado."
    puts "Detalhe do erro: #{e.message}"
  end
  sep(:mais)
end

