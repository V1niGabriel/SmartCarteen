require_relative 'dbConn'

@db.execute_batch <<-SQL
  CREATE TABLE IF NOT EXISTS produtos (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    tipo VARCHAR(45),
    preco DECIMAL(5,2) NOT NULL
  );

  CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(80)
  );

  CREATE TABLE IF NOT EXISTS vendas (
    id_venda INTEGER PRIMARY KEY ,
    data_da_compra DATETIME DEFAULT CURRENT_TIMESTAMP,
    cliente_ID VARCHAR(50) NOT NULL,

    FOREIGN KEY (cliente_ID) REFERENCES clientes(id)
  );

  CREATE TABLE IF NOT EXISTS itens_da_venda (
    id_item_venda INTEGER PRIMARY KEY NOT NULL,
    id_produto INTEGER NOT NULL,
    id_venda INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,

    FOREIGN KEY (id_produto) REFERENCES produtos(id),
    FOREIGN KEY (id_venda) REFERENCES vendas(id_venda)
  );
SQL