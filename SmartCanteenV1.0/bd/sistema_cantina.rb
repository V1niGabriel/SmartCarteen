#Construção do banco de dados

require 'sqlite3'

db = SQLite3::Database.new "SmartCanteenV1.0/bd/sistema_cantina.db"

#Faz com que os resultados venham como Hash (mais fácil de ler) em vez de Array
db.results_as_hash = true

db.execute_batch <<-SQL
  CREATE TABLE IF NOT EXISTS produtos (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(45),
    tipo VARCHAR(45),
    preco DECIMAL(5,2)
  );

  CREATE TABLE IF NOT EXISTS clientes (
    matricula VARCHAR(50) PRIMARY KEY,
    nome VARCHAR(80)
  );

  CREATE TABLE IF NOT EXISTS vendas (
    id_venda INTEGER PRIMARY KEY,
    data_da_compra DATETIME DEFAULT CURRENT_TIMESTAMP,
    cliete_matricula VARCHAR(50),

    FOREIGN KEY (cliete_matricula) REFERENCES clientes(matricula)
  );

  CREATE TABLE IF NOT EXISTS itens_da_venda (
    id_item_venda INTEGER PRIMARY KEY,
    id_produto INTEGER,
    id_venda INTEGER,
    quantidade INTEGER,

    FOREIGN KEY (id_produto) REFERENCES produtos(id),
    FOREIGN KEY (id_venda) REFERENCES vendas(id_venda)
  );
SQL

