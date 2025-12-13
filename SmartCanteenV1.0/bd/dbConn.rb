require 'sqlite3'

@db = SQLite3::Database.new "SmartCanteenV1.0/bd/sistema_cantina.db"

#Habilita o uso de chaves estrangeiras
@db.execute("PRAGMA foreign_keys = ON")

#Faz com que os resultados venham como Hash (mais fácil de ler) em vez de Array
@db.results_as_hash = true