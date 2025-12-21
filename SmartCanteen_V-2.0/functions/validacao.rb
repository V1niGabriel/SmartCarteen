def verifica_registro_existe(tabela, valor, coluna = "id")
  query = "SELECT 1 FROM #{tabela} WHERE #{coluna} = ? LIMIT 1"
  
  resultado = @db.execute(query, [valor])
  return resultado.any?
end

def tabela_vazia(tabela)
  query = "SELECT 1 FROM #{tabela} LIMIT 1"
  
  resultado = @db.execute(query)
  return resultado.empty?
end