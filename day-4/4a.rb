require 'set'

sum = 0
IO.foreach("4.txt").each_with_index do |line, index|
	card, winners, my_numbers = *line.chomp.split(/[:|]/)

	winners = winners.split(' ').map { |x| x.to_i }.to_set
	my_numbers = my_numbers.split(' ').map { |x| x.to_i }

	count = 0
	my_numbers = my_numbers.each { |x| count += 1 if winners.include?(x) }
	if 0 != count
		points = 2 ** (count-1)
		puts "#{card} #{count} winners, #{points} points"
		sum += points
	end
end

puts sum
