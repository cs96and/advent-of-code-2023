RED_MAX = 12
GREEN_MAX = 13
BLUE_MAX = 14

sum = 0
IO.foreach("../inputs/day-2/2.txt") do |line|
	m = line.match(/Game\s*(\d+):\s*(.*)/)
	game_id = m[1].to_i
	rest = m[2]

	red = green = blue = 0

	rest.split(/[,;]\s*/).each do |draw|
		m2 = draw.match(/(\d+)\s*(.*)/)
		count = m2[1].to_i

		case m2[2]
		when 'red'
			red = [red, count].max
		when 'green'
			green = [green, count].max
		when 'blue'
			blue = [blue, count].max
		end
	end

	power = red * green * blue
	puts "Game #{game_id}: #{red} red, #{green} green, #{blue} blue = power #{power}"

	sum += power
end

puts sum
