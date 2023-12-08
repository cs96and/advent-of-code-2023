require 'set'

def calculate_distance(time, max_time)
	return time * (max_time - time)
end

def find_winners(time, best_distance)
	winners = []
	last = i = 0
	while i <= time
		winners << i if calculate_distance(i, time) > best_distance
		i += 1
	end
	return winners
end


races = {}

IO.foreach("6.txt").each_with_index do |line, index|
	line.chomp!

	name, numbers = line.split(' ', 2)
	numbers = numbers.split(' ')

	if name == "Time:"
		numbers.each do |number|
			races[number.to_i] = 0
		end
	elsif name == "Distance:"
		races.each_key.with_index do |key, index|
			races[key] = numbers[index].to_i
		end
	end
end

sum = 1
races.each do |time, distance|
	winners = find_winners(time, distance)
	puts "Time #{time}:  #{winners.size} Winners: #{winners}"
	sum *= winners.size
end

puts sum
