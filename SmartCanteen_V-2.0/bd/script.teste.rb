require_relative 'dbConn'

# Ativa a verificação de Chaves Estrangeiras
@db.execute("PRAGMA foreign_keys = ON;")

@db.execute_batch <<-SQL
  -- Limpeza para evitar conflitos de estrutura anterior
  DROP TABLE IF EXISTS itens_da_venda;
  DROP TABLE IF EXISTS vendas;
  DROP TABLE IF EXISTS funcionarios;
  DROP TABLE IF EXISTS cargos;
  DROP TABLE IF EXISTS produtos;
  DROP TABLE IF EXISTS clientes;

  --1. Tabela de cargos
  CREATE TABLE cargos (
    idcargos INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_cargo VARCHAR(45) NOT NULL
  );

  -- 2. Tabela de Funcionários
  CREATE TABLE funcionarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(45) NOT NULL,
    CPF VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(11) NOT NULL,
    cargos_idcargos INTEGER NOT NULL,
    FOREIGN KEY (cargos_idcargos) REFERENCES cargos(idcargos)
  );

  -- 3. Tabela de Clientes
  CREATE TABLE clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(80) NOT NULL
  );

  -- 4. Tabela de Produtos
  CREATE TABLE produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(45) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    preco DECIMAL(5,2) NOT NULL
  );

  -- 5. Tabela de Vendas
  CREATE TABLE vendas (
    id_venda INTEGER PRIMARY KEY AUTOINCREMENT,
    data_da_compra DATETIME NOT NULL,
    cliente_ID INTEGER NOT NULL,
    id_vendedor INTEGER NOT NULL,
    FOREIGN KEY (cliente_ID) REFERENCES clientes(id),
    FOREIGN KEY (id_vendedor) REFERENCES funcionarios(id)
  );

  -- 6. Tabela de Itens da Venda
  CREATE TABLE itens_da_venda (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_produto INTEGER NOT NULL,
    id_venda INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    FOREIGN KEY (id_produto) REFERENCES produtos(id),
    FOREIGN KEY (id_venda) REFERENCES vendas(id_venda)
  );
SQL

# --- Alimentação dos Dados ---

begin
  @db.transaction do
    # Inserindo 10 Cargos
    cargos_lista = ["Gerente", "Vendedor", "Analista", "Estagiário", "Supervisor", "Diretor", "Coordenador", "Atendente", "Caixa", "Suporte"]
    cargos_lista.each { |c| @db.execute("INSERT INTO cargos (nome_cargo) VALUES (?)", [c]) }

    # Inserindo 10 Clientes e 10 Produtos
    10.times do |i|
      @db.execute("INSERT INTO clientes (nome) VALUES (?)", ["Cliente #{i+1}"])
      @db.execute("INSERT INTO produtos (nome, tipo, preco) VALUES (?, ?, ?)", ["Produto #{i+1}", "Geral", 15.50 + i])
    end

    # Inserindo 10 Funcionários
    10.times do |i|
      @db.execute("INSERT INTO funcionarios (nome, CPF, telefone, cargos_idcargos) VALUES (?, ?, ?, ?)", 
                 ["Funcionario #{i+1}", "123.456.789-#{i}#{i}", "119888#{i}#{i}", i + 1])
    end

    # Inserindo 10 Vendas com Datas
    10.times do |i|
      # Correção: Gerando a data atual formatada para o SQLite
      data_agora = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      @db.execute("INSERT INTO vendas (data_da_compra, cliente_ID, id_vendedor) VALUES (?, ?, ?)", 
                 [data_agora, i + 1, i + 1])
    end

    # Inserindo Itens da Venda
    10.times do |i|
      @db.execute("INSERT INTO itens_da_venda (id_produto, id_venda, quantidade) VALUES (?, ?, ?)", [i + 1, i + 1, 1])
    end
  end
  puts "✅ Banco de dados corrigido e alimentado com sucesso!"
rescue SQLite3::Exception => e
  puts "❌ Erro ao alimentar banco: #{e.message}"
end