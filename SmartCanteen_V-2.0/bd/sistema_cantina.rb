require_relative 'dbConn'

@db.execute_batch <<-SQL
  CREATE TABLE IF NOT EXISTS produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(45) NOT NULL,
    tipo VARCHAR(45) NOT NULL,
    preco DECIMAL(5,2) NOT NULL
  );

  CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(45) NOT NULL
  );

  CREATE TABLE IF NOT EXISTS cargos (
    idcargos INTEGER PRIMARY KEY NOT NULL AUTOINCREMENT,
    nome_cargo VARCHAR(50) NOT NULL
  );

  CREATE TABLE IF NOT EXISTS funcionarios (
    id INTEGER PRIMARY KEY NOT NULL AUTOINCREMENT,
    nome VARCHAR(45) NOT NULL,
    CPF VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(11) NOT NULL,
    cargos_idcargos INTEGER NOT NULL, --chave estrangeira

    FOREIGN KEY (cargos_idcargos) REFERENCES cargos(idcargos)
  );

  CREATE TABLE IF NOT EXISTS vendas (
    id_venda INTEGER PRIMARY KEY AUTOINCREMENT,
    data_da_compra DATETIME DEFAULT CURRENT_TIMESTAMP,
    cliente_ID INTEGER NOT NULL,
    id_vendedor INTEGER,

    FOREIGN KEY (cliente_ID) REFERENCES clientes(id),
    FOREIGN KEY (id_vendedor) REFERENCES funcionarios(id)
  );

  CREATE TABLE IF NOT EXISTS itens_da_venda (
    id INTEGER PRIMARY KEY NOT NULL AUTOINCREMENT,
    id_produto INTEGER NOT NULL,
    id_venda INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,

    FOREIGN KEY (id_produto) REFERENCES produtos(id),
    FOREIGN KEY (id_venda) REFERENCES vendas(id_venda)
  );
SQL