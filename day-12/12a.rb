require 'set'

Warning[:experimental] = false

class SpringRow
	def initialize(line)
		@row, numbers = line.split(' ')
		@criteria = numbers.split(',').map(&:to_i)
	end

	def count_permutations
		num_criteria = @criteria.reduce(&:+)
		num_broken = @row.count('#')
		num_unknown = @row.count('?')
		to_find = num_criteria - num_broken

		min = (2 ** to_find) - 1
		max = min << (num_unknown - to_find)

		count = min.upto(max).count do |p|
			new_row = to_new_row(p)
			correct?(new_row)
		end
		count
	end

	def to_new_row(permutation_number)
		i = offset = 0
		new_row = @row.dup

		while offset = new_row.index('?', offset)
			ch = (0 == permutation_number & 2**i ? '.' : '#')
			new_row[offset] = ch
			i += 1
		end
		new_row
	end

	def correct?(row)
		broken_sections = row.scan(/#+/)
		return (broken_sections.size == @criteria.size) && broken_sections.each_with_index.all? { |section, index| section.size == @criteria[index] }
	end

end

rows = IO.foreach("../inputs/day-12/12.txt", chomp:true).map { |line| SpringRow.new(line) }
Ractor.make_shareable(rows)

NUM_RACTORS = 15
ractors = []
(0...NUM_RACTORS).each do |i|
	Ractor.make_shareable(i, copy: true)
	ractors << Ractor.new(rows, i, NUM_RACTORS) do |rows, i, num|
		sum = 0
		while i < rows.size
			count = rows[i].count_permutations
			sum += count
			puts "#{i.to_s.rjust(4)} => #{count}"
			i += num
		end
		sum
	end
end

puts ractors.sum(&:take)

