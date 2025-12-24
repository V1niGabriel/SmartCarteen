<<<<<<< HEAD
class Pessoa
  attr_accessor :nome

  def initialize(nome)
=======
require_relative '../config/path'
class Pessoa
  attr_accessor :id, :nome 

  def initialize(nome, id = nil)
    @id = id
>>>>>>> bea5fcd3dd455b07d748961fbdf6179d168c7ae1
    @nome = nome
  end
end