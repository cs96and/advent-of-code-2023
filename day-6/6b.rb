require 'set'

def calculate_distance(time, max_time)
	return time * (max_time - time)
end

def find_winners(time, best_distance)
	winners = []
	
	# Find the first winner (We're assuming the distances are increasing up to half way)
	first_winner = (0..time/2).bsearch { |i| calculate_distance(i, time) > best_distance }

	# Walk from half way until the distance starts dropping
	prev_distance = 0
	pivot = time/2
	while pivot <= time
		dist = calculate_distance(pivot, time)
		break if dist < prev_distance
		prev_distance = dist
		pivot += 1
	end

	puts "First winner = #{first_winner}"
	puts "Pivot = #{pivot}"

	last_winner = time.downto(pivot).to_a.bsearch { |i| calculate_distance(i, time) > best_distance }

	puts "last = #{last_winner}"

	return (first_winner..last_winner)
end


time = 0
distance = 0

IO.foreach("6.txt").each_with_index do |line, index|
	line.chomp!

	name, numbers = line.split(' ', 2)
	value = numbers.split(' ').join.to_i

	if name == "Time:"
		time = value
	elsif name == "Distance:"
		distance = value
	end
end

puts "Time: #{time}:  Distance to beat: #{distance}"

sum = 1

winners = find_winners(time, distance)
puts "Time #{time}:  #{winners.size} Winners: #{winners.size}"
