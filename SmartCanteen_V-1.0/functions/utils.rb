def sep(tipo = :duplo)
  case tipo
  when :duplo
    puts "=" * 50
  when :simples
    puts "-" * 50
  when :estrela
    puts "*" * 50
  when :mais
    puts "+" * 50
  when :traco
    puts "|" * 50
  else
    puts "=" * 50
  end
end