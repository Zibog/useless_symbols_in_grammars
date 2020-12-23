class Algo
  # Читаем файл
  def read_file(fname)
    @fname = fname
    data = IO.read(@fname)
    # Получаем алфавит
    @alphabet = data.chars.select { |char| char.match?(/[a-z]/) }
    @prods = {}
    # Для удобства создаём хэш, где ключ-левый нетерминал
    data.split.each do |prod|
      prod_temp = prod.gsub(/->/, '|').split('|')
      @prods[prod_temp[0]] = prod_temp[1..-1]
    end
  end

  # Удаление бесплодных символов
  def remove_barren
    current_set = {}, prev_set = {}
    loop do
      current_set = @prods.select do |key, value|
        # Символ должен быть в объединении алфавита и предыдущего множества
        prev_set.include?(key) || value.any? do |right|
          @alphabet.concat(prev_set.keys).combination(right.length).include?(right.split(//))
        end
      end
      break if current_set == prev_set

      prev_set = current_set
    end
    @prods.delete_if { |key| !current_set.include?(key) }
    @prods.each do |key, value|
      value = value.select do |right|
        @alphabet.concat(current_set.keys).combination(right.length).include?(right.split(//))
      end
    end
    @prods
  end

  # Удаление недостижимых символов
  def remove_unreachable
    prev_set = [@prods.first[0]]
    split_onto_flatten(@prods.first[1], prev_set)
    current_set = prev_set
    loop do
      @prods.each do |key, value|
        #next if prev_set.include? key
        split_onto_flatten(value, current_set) if find_n(prev_set).include? key
      end
      #current_set = @prods.select do |key, value|
      #  prev_set.include?(key) || value.any? do |right|
      #    @alphabet.concat(@prods.keys).combination(right.length).include?(right.split(//))
      #  end
      #end
      break if current_set == prev_set

      prev_set = current_set
    end
    @prods.delete_if { |key| !current_set.intersection(@prods.keys).include?(key) }
    @prods.each do |key, value|
      value = value.select do |right|
        current_set.combination(right.length).include?(right.split(//))
      end
    end
    @alphabet = @alphabet.intersection(current_set.select { |char| char.match?(/[a-z]/) })
    @prods
  end

  # Хелпер, который ищет нетерминалы
  def find_n(set)
    set.select { |char| char.match?(/[A-Z]/) }
  end

  # Хелпер, разбивающий значение на плоский массив
  def split_onto_flatten(value, arr)
    value.each do |sym|
      arr << sym.split(//)
    end
    arr.flatten!.uniq!
  end

  # Удаляет бесполезные символы
  def remove_useless
    remove_barren
    remove_unreachable
    @prods
  end

  # Оформляем вывод
  def print
    @prods.each do |key, value|
      p "#{key}->#{value.join("|")}"
    end
  end
end

@a = Algo.new
@a.read_file("321.txt")
p "========================="
p "First grammar:"
@a.print
p "-------------------------"
prods = @a.remove_barren
p "Removed barren symbols:"
@a.print
p "========================="
@a.read_file("213.txt")
p "Second grammar:"
@a.print
p "-------------------------"
prods = @a.remove_unreachable
p "Removed unreachable symbols:"
@a.print
p "========================="
@a.read_file("231.txt")
p "Third grammar:"
@a.print
p "-------------------------"
prods = @a.remove_useless
p "Removed both types of useless symbols:"
@a.print
p "There is no useless symbols, it's true"
p "========================="
