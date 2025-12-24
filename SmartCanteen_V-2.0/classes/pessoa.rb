require_relative '../config/path'
class Pessoa
  attr_accessor :id, :nome 

  def initialize(nome, id = nil)
    @id = id
    @nome = nome
  end
end