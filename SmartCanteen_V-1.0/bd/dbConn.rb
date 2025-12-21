require 'sqlite3'

db_path = File.join(__dir__, 'sistema_cantina.db')

@db = SQLite3::Database.new(db_path)

#Habilita o uso de chaves estrangeiras
@db.execute("PRAGMA foreign_keys = ON")

#Faz com que os resultados venham como Hash (mais fácil de ler) em vez de Array
@db.results_as_hash = true