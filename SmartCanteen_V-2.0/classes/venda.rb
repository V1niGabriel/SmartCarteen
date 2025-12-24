require_relative '../config/path'

class Venda
  attr_accessor :cliente, :itens, :data

  def initialize(cliente)
    @cliente = cliente # Objeto Cliente
    @itens = []        # Array para guardar objetos ItemVenda
    # @data = Time.now
  end

  def adicionar_item(produto, quantidade)
    # Cria um novo objeto ItemVenda e adiciona na lista
    novo_item = ItemVenda.new(produto, quantidade)
    @itens << novo_item
  end

  def total_venda
    @itens.sum { |item| item.total_item }
  end

  def salvar
    id_funcionario= Sessao.atual['id']
    # Usamos transaction para garantir que se um item falhar, a venda toda é cancelada
    DB.transaction do
      # 1. Salva o cabeçalho da Venda
      DB.execute("INSERT INTO vendas (cliente_ID, id_vendedor) VALUES (?, ?)", [@cliente.id, id_funcionario])
      
      # 2. Pega o ID que o banco acabou de criar para essa venda
      id_venda_gerado = DB.last_insert_row_id

      # 3. Percorre cada item e manda ele se salvar vinculando a este ID
      @itens.each do |item|
        item.salvar(id_venda_gerado)
      end
    end
    return true
  rescue SQLite3::Exception => e
    puts "Erro crítico ao salvar a venda: #{e.message}"
    return false
  end
end