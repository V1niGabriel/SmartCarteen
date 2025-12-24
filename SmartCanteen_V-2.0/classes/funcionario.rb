require_relative '../config/path'
require 'digest'

class Funcionario < Pessoa
  attr_accessor :telefone, :cpf, :cargo, :senha_hash

  def initialize(nome, cpf, telefone, cargo_id, senha, id = nil)
    super(nome, id) 
    @cpf = cpf
    @telefone = telefone
    @cargo_id = cargo_id
    @senha_hash = Digest::SHA256.hexdigest(senha)
  end

  def salvar()
    begin
      query = "INSERT INTO funcionarios (nome, CPF, telefone, cargos_idcargos, senha_hash) VALUES (?, ?, ?, ?, ?)"
      DB.execute(query, [@nome, @cpf, @telefone, @cargo_id, @senha_hash])
    rescue SQLite3::Exception => e
      puts "Erro ao salvar funcionario: #{e.message}"
    end
  end
end 

class Cargo
  attr_accessor :id, :nome

  def initialize(id, nome)
    @id = id
    @nome = nome
  end

  def self.getcargos()
    begin
      cargos = DB.execute("SELECT * FROM cargos")
      cargos.each_slice(3) do |grupo|
      grupo.each do |cargo|
        printf("| ID: %-2s - %-15s ", cargo['idcargos'], cargo['nome_cargo'][0..24])  
      end
      puts "|" 
    end
    rescue SQLite3::Exception => e
      puts "Erro ao buscar cargos: #{e.message}"
    end
  end
end