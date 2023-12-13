class String
	# colorization
	def colorize(color_code)
	  "\e[#{color_code}m#{self}\e[0m"
	end
  
	def red
	  colorize(31)
	end

	def green
		colorize(32)
	end
end  

def compare_columns(pattern, col1, col2)
	pattern.all? { |row| row[col1] == row[col2] }
end

def find_vertical_reflection(pattern)
	length = pattern[0].length
	
	start_col = 0
	while (start_col < length-2)
		# Find a column the same as the previous one
		start_col = (start_col...length-1).find { |c| compare_columns(pattern, c, c+1) }
		break if start_col.nil?
		
		# Check everything outwards matches
		match = true
		left = start_col-1
		right = start_col+2
		while (left >= 0) && (right < length)
			if !compare_columns(pattern, left, right)
				match = false
				break
			end
			left -= 1
			right += 1
		end

		return start_col + 1 if match

		start_col += 1
	end
	return 0
end

def find_horizontal_reflection(pattern)
	length = pattern.length
	
	start_row = 0
	while (start_row < length-2)
		# Find a row the same as the previous one
		start_row = (start_row...length-1).find { |c| pattern[c] == pattern[c+1] }
		break if start_row.nil?
		
		# Check everything outwards matches
		match = true
		top = start_row-1
		bottom = start_row+2
		while (top >= 0) && (bottom < length)
			if pattern[top] != pattern[bottom]
				match = false
				break
			end
			top -= 1
			bottom += 1
		end

		return start_row + 1 if match

		start_row += 1
	end
	return 0
end

def display_pattern_with_vertical_marker(pattern, col)
	puts "><".rjust(col+1).green
	pattern.each { |line| puts line }
	puts "><".rjust(col+1).green
end

def display_pattern_with_horizontal_marker(pattern, row)
	pattern.each_with_index do |line, i|
		ch = (i == row - 1? 'v' : (i == row ? '^' : ' '))
		puts "#{ch.green}#{line}#{ch.green}"
	end
end


patterns = []
current_pattern = []
IO.foreach("13.txt", chomp:true) do |line|
	if 0 == line.length
		patterns << current_pattern
		current_pattern = []
	else
		current_pattern << line
	end
end
patterns << current_pattern

sum = 0
patterns.each do |pattern|
	result = find_vertical_reflection(pattern)
	if (0 != result)
		puts "Vertical: #{result}"
		display_pattern_with_vertical_marker(pattern, result)
		sum += result
	else
		result = find_horizontal_reflection(pattern)
		if 0 != result
			puts "Horizontal: #{result*100}"
			display_pattern_with_horizontal_marker(pattern, result)
			sum += result * 100
		else
			puts "** NOT FOUND **"
		end
	end
		
	puts
end

puts sum
