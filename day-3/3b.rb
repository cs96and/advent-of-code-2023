
$schematic = []

def check_left(line_no, pos, parts)
	line = $schematic[line_no]
	if 0 != pos
		if m = line[0...pos].match(/.*?(\d+)$/)
			parts << m[1].to_i
		end
	end
end

def check_right(line_no, pos, parts)
	line = $schematic[line_no]
	if m = line[pos+1..-1].match(/^(\d+)/)
		parts << m[1].to_i
	end
end

def check_above(line_no, pos, parts)
	return if 0 == line_no
	line = $schematic[line_no-1]

	if line[pos] =~ /\d/
		parts << get_num_at_pos(line, pos)
	else
		check_left(line_no-1, pos, parts)
		check_right(line_no-1, pos, parts)
	end
end

def check_below(line_no, pos, parts)
	line = $schematic[line_no+1]
	return if line.nil?

	if line[pos] =~ /\d/
		parts << get_num_at_pos(line, pos)
	else
		check_left(line_no+1, pos, parts)
		check_right(line_no+1, pos, parts)
	end
end

def get_num_at_pos(line, pos)
	start_pos = line.rindex(/[^\d]/, pos)
	start_pos = -1 if start_pos.nil?

	end_pos = line.index(/[^\d]/, pos)
	end_pos = -1 if end_pos.nil?

	num = line[start_pos+1...end_pos].to_i
end

def check_around(line_no, pos)
	parts = []

	part = check_left(line_no, pos, parts)
	part = check_right(line_no, pos, parts)
	part = check_above(line_no, pos, parts)
	part = check_below(line_no, pos, parts)

	return (parts.size() == 2) ? parts : nil
end


IO.foreach("../inputs/day-3/3.txt").each_with_index do |line, index|
	$schematic[index] = line.chomp
end

sum = 0
$schematic.each_with_index do |line, index|
	offset = 0
	while true
		pos = line.index('*', offset)
		break if pos.nil?
		offset = pos + 1

		parts = check_around(index, pos)
		if parts
			puts "#{index+1} : #{parts[0]} * #{parts[1]}"
			sum += parts[0] * parts[1]
		end
	end
end

puts sum
