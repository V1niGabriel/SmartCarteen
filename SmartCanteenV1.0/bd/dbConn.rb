require 'sqlite3'

  @db = SQLite3::Database.new "bd/sistema_cantina.db"

  #Faz com que os resultados venham como Hash (mais fácil de ler) em vez de Array
  @db.results_as_hash = true