=begin
  5. Etapa 5: Vamos criar o “menu de opções” do nosso sistema
5.1. Crie uma lógica (usando loop e gets.chomp) que possibilite ao usuário:
5.1.1. "1 - Cadastrar novo Produto"
5.1.2. "2 - Cadastrar novo Cliente"
5.1.3. "3 - Registrar Venda"
5.1.4. "4 – Relatórios"
5.1.4.1. "4.1 - Listar Todos os Clientes"
5.1.4.2. "4.2 - Listar Todos os Produtos"
5.1.4.3. "4.3 - Listar Todas as vendas"
5.1.4.4. 5.1.4.5. 5.1.5. "5 - Sair"
"4.4 – Apresentar o total do valor vendido em um dia específico"
"4.5 – Apresentar qual produto é mais vendido"
=end

require_relative 'functions/menu_principal.rb'
require_relative 'functions/menu_relatorio.rb'

def inicia_sistema()
  opcao = 0
  while opcao != 5
    puts "========================================="
    print "Escolha uma opção: "
    puts "1 - Cadastrar novo Produto"
    puts "2 - Cadastrar novo Cliente"
    puts "3 - Registrar Venda" 
    puts "4 - Relatórios"
    puts "5 - Sair"
    puts "========================================="
    
    opcao = gets.chomp.to_i

    case opcao
    when 1
      cadastrarProduto()
    when 2
      cadastrarCliente()
    when 3
      registrarVenda()
    when 4
      menuRelatorios()
    when 0
      puts "Saindo do sistema..."
      puts "========================================="
    else
      puts "Opção inválida. Tente novamente."
    end
  end
end
  
end

def menuRelatorios()
  puts "========================================="
  puts "Menu de Relatórios"
  puts "1 - Listar Todos os Clientes"
  puts "2 - Listar Todos os Produtos"
  puts "3 - Listar Todas as Vendas"
  puts "4 - Total do valor vendido em um dia específico"
  puts "5 - Produto mais vendido"
  puts "6 - Voltar ao menu principal"
  puts "========================================="

  when opcaoRelatorio = gets.chomp.to_i
    case opcaoRelatorio
    when 1
      listarClientes()
    when 2
      listarProdutos()
    when 3
      listarVendas()
    when 4
      totalVendasDia()
    when 5
      produtoMaisVendido()
    when 6
      return
    else
      puts "Opção inválida. Tente novamente."
    end
end

