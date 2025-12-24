class ItemVenda
  attr_accessor :produto, :quantidade, :preco_unitario

  # Recebe o Objeto Produto inteiro, não apenas o ID
  def initialize(produto, quantidade)
    @produto = produto
    @quantidade = quantidade
    @preco_unitario = produto.preco # Gravamos o preço do momento da venda
  end

  def total_item
    @quantidade * @preco_unitario
  end

  # O Item se salva, mas precisa saber o ID da venda pai
  def salvar(id_venda_pai)
    DB.execute(
      "INSERT INTO itens_da_venda (id_produto, id_venda, quantidade) VALUES (?, ?, ?)",
      [@produto.id, id_venda_pai, @quantidade]
    )
  end
end