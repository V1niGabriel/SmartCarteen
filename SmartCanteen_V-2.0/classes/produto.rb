require_relative '../config/path'

class Produto
  attr_accessor :id, :nome, :tipo, :preco

  def initialize(nome, tipo, preco, id = nil)
    @nome = nome
    @tipo = tipo
    @preco = preco
    @id = id
  end

  # Método de Classe (Estático) para salvar
  def salvar
    begin
      DB.execute("INSERT INTO produtos (nome, tipo, preco) VALUES (?, ?, ?)", 
        [@nome, @tipo, @preco])

      #Retorna true ao funcionar
      return true
    rescue SQLite3::Exception => e
      puts "Erro ao salvar no banco: #{e.message}"
      retur false
    end
  end
  
  # Método para buscar todos e retornar OBJETOS, não hash do banco
  def self.todos
    rows = DB.execute("SELECT * FROM produtos")
    rows.map do |row|
      Produto.new(row['nome'], row['tipo'], row['preco'], row['id'])
    end
  end

  #Método de busca por id
  def self.buscar_por_id(id)
    row = DB.get_first_row("SELECT * FROM produtos WHERE id = ?", [id])
    return row ? Produto.new(row['nome'], row['tipo'], row['preco'], row['id']) : nil
  end
end