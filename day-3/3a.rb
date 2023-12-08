
$schematic = []

def is_symbol(ch)
	return !ch.nil? && ch != '.' && !(ch =~ /\d/)
end

def check_around(line_no, start_pos, end_pos)
	# check current line
	line = $schematic[line_no]
	return true if (start_pos != 0) && is_symbol(line[start_pos-1])
	return true if is_symbol(line[end_pos])

	start_pos -= 1 if 0 != start_pos

	# check line above
	if 0 != line_no
		line = $schematic[line_no-1]
		(start_pos..end_pos).each do |pos|
			return true if is_symbol(line[pos])
		end
	end

	# check line below
	line = $schematic[line_no+1]
	if (line)
		(start_pos..end_pos).each do |pos|
			return true if is_symbol(line[pos])
		end
	end

	return false
end

def output_part(line_no, start_pos, end_pos)
	start_pos -= 1 if 0 != start_pos
	
	if 0 != line_no
		puts $schematic[line_no-1][start_pos..end_pos]
	end

	puts $schematic[line_no][start_pos..end_pos]

	last_line = $schematic[line_no+1]
	if last_line
		puts last_line[start_pos..end_pos]
	end
	puts
end

IO.foreach("3.txt").each_with_index do |line, index|
	$schematic[index] = line.chomp
end

sum = 0
$schematic.each_with_index do |line, index|
	trimmed = 0
	while true
		m = line.match(/(\d+)/)
		break if !m

		start_pos = m.offset(1)[0]
		end_pos = m.offset(1)[1]

		if (check_around(index, start_pos+trimmed, end_pos+trimmed))
			output_part(index, start_pos+trimmed, end_pos+trimmed)
			sum += m[1].to_i
		end

		trimmed += end_pos
		line = line[end_pos..-1]
	end
end

puts sum
