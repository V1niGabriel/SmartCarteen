system("cls")

require_relative 'config/path'

def inicia_sistema()
  prompt = TTY::Prompt.new
  logado = false

  loop do
    system("cls")
    sep()
    puts "🔒 LOGIN NECESSÁRIO"
    puts "(Digite '0' no CPF para fechar o programa)"
    sep()

    print "CPF: "
    cpf = gets.chomp

    if cpf == '0'
      puts "Saindo..."
      return 
    end

    senha = prompt.mask("Senha:")

    if login(cpf, senha)
      puts "\n✅ Login efetuado com sucesso!"
      sleep(1)
      logado = true
      break 
    else
      puts "\n❌ Dados incorretos!"
      puts "Tente novamente..."
      sleep(1.5) 
    end
  end
  
  if logado
    menu_opcoes = {
      "Cadastrar novo Produto" => 1,
      "Cadastrar novo Cliente" => 2,
      "Registrar Venda" => 3,
      "Relatórios" => 4,
    }
    if Sessao.atual['cargo'] == 'Gerente'
      menu_opcoes["Cadastrar novo Funcionário"] = 5
    end
    menu_opcoes["Sair (Logout)"] = 0

    opcao = -1
    while opcao != 0      
      sep()
      puts "MENU PRINCIPAL - Usuário: #{Sessao.atual['nome']}" 
      sep()
      opcao = prompt.select("Escolha uma opção:", menu_opcoes)
      sep()

      case opcao
      when 1
        cadastrarProduto()
      when 2
        cadastrarCliente()
      when 3
        registrarVenda()
      when 4
        puts "Entrando no menu de relatórios..."
        menuRelatorios()
      when 5
        if Sessao.atual['cargo'] == 'Gerente'
          cadastrarFuncionario()
        else
          puts "Opção inválida."
        end
      when 0
        puts "Fazendo logout..."
        logout()
        sep()
      else
        puts "Opção #{opcao} inválida."
        sleep(1)
      end
    end
  end
end
  

def menuRelatorios()
  prompt = TTY::Prompt.new
  opcoes_relatorio = {
      "Listar Todos os Clientes" => 1,
      "Listar Todos os Produtos" => 2,
      "Listar Todas as Vendas" => 3,
      "Total vendido em um dia específico" => 4,
      "Produto mais vendido" => 5,
      "Total de atendimentos por funcionário (Dia)" => 6,
      "Total vendido por funcionário (Dia)" => 7,
      "Voltar ao menu principal" => 0
    }

  opcaoRelatorio = -1
  while opcaoRelatorio != 0
    sep()
    opcaoRelatorio = prompt.select("Menu de Relatórios", opcoes_relatorio, per_page: 10)
    sep()
    
    case opcaoRelatorio
    when 1
      listarClientes()
    when 2
      listarProdutos()
    when 3
      listarVendas()
    when 4
      puts "Digite uma data no formato DD-MM-AAAA"
      data = gets.chomp
      data_valida = validarData(data)
      totalVendasDia(data_valida)
    when 5
      produtoMaisVendido()
    when 6
    print "Digite a data para o relatório (DD-MM-AAAA): "
    data_input = gets.chomp
    data_valida = validarData(data_input)
    if data_valida
      atendimentosPorFuncionarioDia(data_valida)
    end
    when 7
    print "Digite a data para o relatório (DD-MM-AAAA): "
    data_input = gets.chomp
    data_valida = validarData(data_input)
    if data_valida
      valorVendidoPorFuncionarioDia(data_valida)
    end
    when 0
      puts "Retornando ao menu principal..."
      return
    else
      puts "Opção inválida. Tente novamente."
    end
  end
end


inicia_sistema()