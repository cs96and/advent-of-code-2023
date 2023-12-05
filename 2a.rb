RED_MAX = 12
GREEN_MAX = 13
BLUE_MAX = 14

sum = 0
IO.foreach("2.txt") do |line|
	m = line.match(/Game\s*(\d+):\s*(.*)/)
	game_id = m[1].to_i
	rest = m[2]

	ok = true
	rest.split(/[,;]\s*/).each do |draw|
		m2 = draw.match(/(\d+)\s*(.*)/)
		case m2[2]
		when 'red'
			max = RED_MAX
		when 'green'
			max = GREEN_MAX
		when 'blue'
			max = BLUE_MAX
		end

		if m2[1].to_i > max
			ok = false
			break
		end
	end

	sum += game_id if ok
end

puts sum
