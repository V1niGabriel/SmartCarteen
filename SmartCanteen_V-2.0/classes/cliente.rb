require_relative 'pessoa'

class Cliente < Pessoa 

  def salvar
    begin
      DB.execute("INSERT INTO clientes (nome) VALUES (?)", [@nome])
      return true
    rescue SQLite3::Exception => e
      puts "Erro ao salvar cliente: #{e.message}"
      retur false
    end
  end

  def self.buscar_por_id(id)
    row = DB.get_first_row("SELECT * FROM clientes WHERE id = ?", [id])
    if row
      return Cliente.new(row['nome'], row['id'])
    else
      return nil
    end
  end
end