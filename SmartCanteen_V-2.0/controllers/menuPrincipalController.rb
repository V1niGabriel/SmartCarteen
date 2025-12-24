require_relative '../config/path'
require 'tty-prompt'

def cadastrarProduto()
  sep(:mais)
    print "Digite o nome do produto: "
    nome = gets.chomp

    sep(:simples)
    print "Digite o tipo do produto: " 
    tipo = gets.chomp
 
    sep(:simples)
    print "Digite o preço do produto: "
    preco = gets.chomp.to_f
    sep(:simples)

    #Criação do objeto
    novo_produto = Produto.new(nome, tipo, preco)

    #Persistência
    if novo_produto.salvar
      puts "Produto '#{novo_produto.nome}' cadastrado com sucesso"
    else 
      puts "Falha ao cadastrar produto"
    end

  sep(:mais)
end

def cadastrarCliente()
  sep(:mais)
  begin
    print "Digite o nome do cliente: "
    nome = gets.chomp
    sep(:simples)

    novo_cliente = Cliente.new(nome)

    if novo_cliente.salvar
      puts "Cliente '#{novo_cliente.nome}' cadastrado com sucesso!"
    end

  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
  sep(:mais)
end

def cadastrarFuncionario()
  sep(:mais)
  begin
    print "Digite o nome do funcionário: "
    nome = gets.chomp
    sep(:simples)
    print "Digite o CPF do funcionário: "
    cpf = gets.chomp  
    sep(:simples)
    print "Digite o telefone do funcionário: "
    telefone = gets.chomp
    sep(:simples)
    Cargo.getcargos()
    print "Digite o ID do cargo do funcionário: "
    cargo_id = gets.chomp.to_i
    sep(:simples)
    senha = prompt.mask("Digite a senha do funcionário:")

    novo_funcionario = Funcionario.new(nome, cpf, telefone, cargo_id, senha)

    if novo_funcionario.salvar()
      puts "Funcionario '#{novo_funcionario.nome}' cadastrado com sucesso!"
    end

  rescue StandardError => e
    puts "Erro inesperado: #{e.message}"
  end
  sep(:mais)
end

def registrarVenda()
  # (Mantenha as verificações de tabela_vazia se desejar, ou use Produto.todos(@db).empty?)
  # Verificação de segurança no início
  if DB.nil?
    puts "Erro crítico: Conexão com banco de dados não estabelecida."
    return
  end
  
  sep(:traco)
  listarClientes()
  sep(:traco)
  
  # SELEÇÃO DO CLIENTE 
  cliente_obj = nil
  loop do 
    print "Selecione o cliente pelo ID: "
    id_selecionado = gets.chomp.to_i
    
    # O método estático busca e retorna o Objeto ou nil
    cliente_obj = Cliente.buscar_por_id(id_selecionado)
    
    break if cliente_obj # Se encontrou o objeto, sai do loop
    puts "ID inválido. Cliente não encontrado."
  end
  sep(:simples)

  # INICIALIZA A VENDA 
  # Criamos a venda passando o Objeto Cliente
  nova_venda = Venda.new(cliente_obj)

  carrinho_ativo = true
  
  while carrinho_ativo
    sep(:traco)
    listarProdutos()
    sep(:traco)

    # SELEÇÃO DO PRODUTO 
    produto_obj = nil
    loop do
      print "Selecione o produto pelo ID: "
      id_prod = gets.chomp.to_i
      produto_obj = Produto.buscar_por_id(id_prod)

      break if produto_obj
      puts "ID inválido. Produto não encontrado."
    end
    
    print "Digite a quantidade: "
    qtd = gets.chomp.to_i
    
    # ADICIONANDO AO OBJETO VENDA
    # A classe Venda cuida de criar o ItemVenda internamente
    nova_venda.adicionar_item(produto_obj, qtd)
    puts "Item adicionado! Total parcial: R$ #{nova_venda.total_venda}"

    print "Adicionar mais produtos? (s/n): "
    carrinho_ativo = gets.strip.downcase == 's'
  end

  # --- PERSISTÊNCIA ---
  sep(:mais)
  puts "Finalizando venda..."
  
  if nova_venda.salvar
    puts "Venda registrada com sucesso!"
    puts "Total Final: R$ #{nova_venda.total_venda}"
  else
    puts "Erro ao registrar venda."
  end
  sep(:mais)
end

