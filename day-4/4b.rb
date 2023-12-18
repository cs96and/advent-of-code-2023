require 'set'

cards = {}
cards.default = 0

card = 0
IO.foreach("../inputs/day-4/4.txt").each_with_index do |line, index|
	card, winners, my_numbers = *line.chomp.split(/[:|]/)
	card = card.split(' ')[1].to_i

	winners = winners.split(' ').map { |x| x.to_i }.to_set
	my_numbers = my_numbers.split(' ').map { |x| x.to_i }

	count = 0
	my_numbers = my_numbers.each { |x| count += 1 if winners.include?(x) }

	puts "Card #{card}: winners #{count}"

	if 0 != count
		(card+1..card+count).each do |c|
			puts "Card #{card}: adding #{cards[card] + 1} to card #{c}"
			cards[c] += cards[card] + 1
		end
	end
	cards[card] += 1
end

cards.reject! { |k, v| k > card }
puts cards

sum = 0
cards.each{ |k, v| sum += v }
puts sum
