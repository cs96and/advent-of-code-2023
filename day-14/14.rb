 
def roll_rock_north(field, y, x)
	y -= 1
	while y >= 0 do
		return y+1 if field[y][x] != '.'
		y -= 1
	end
	return 0
end

def roll_rock_south(field, y, x)
	y += 1
	while y < field.length do
		return y-1 if field[y][x] != '.'
		y += 1
	end
	return field.length-1
end

def roll_rock_west(field, y, x)
	x -= 1
	while x >= 0 do
		return x+1 if field[y][x] != '.'
		x -= 1
	end
	return 0
end

def roll_rock_east(field, y, x)
	x += 1
	while x < field[y].length do
		return x-1 if field[y][x] != '.'
		x += 1
	end
	return field[y].length-1
end

def tilt_field_north(field)
	for y in 1...field.length do
		field[y].each_char.with_index do |ch, x|
			next if ch != 'O'
	
			new_y = roll_rock_north(field, y, x)
			if y != new_y
				field[y][x] = '.'
				field[new_y][x] = 'O'
			end
		end
	end
	field
end

def tilt_field_south(field)
	(field.length-2).downto(0) do |y|
		field[y].each_char.with_index do |ch, x|
			next if ch != 'O'
	
			new_y = roll_rock_south(field, y, x)
			if y != new_y
				field[y][x] = '.'
				field[new_y][x] = 'O'
			end
		end
	end
	field
end

def tilt_field_west(field)
	for y in 0...field.length do
		field[y][1..].each_char.with_index do |ch, x|
			x+=1
			next if ch != 'O'
	
			new_x = roll_rock_west(field, y, x)
			if x != new_x
				field[y][x] = '.'
				field[y][new_x] = 'O'
			end
		end
	end
	field
end

def tilt_field_east(field)
	for y in 0...field.length do
		(field[y].length-2).downto(0) do |x|
			ch = field[y][x]
			next if ch != 'O'
	
			new_x = roll_rock_east(field, y, x)
			if x != new_x
				field[y][x] = '.'
				field[y][new_x] = 'O'
			end
		end
	end
	field
end

def weigh(field)
	sum = 0
	field.each_with_index do |line, y|
		line_weight = field.length-y
		sum += line.count('O') * line_weight
	end
	return sum
end

field = IO.foreach("14.txt", chomp:true).to_a

puts "Part 1: #{weigh(tilt_field_north(field.dup))}\n"

ITERATIONS = 1000000000
field_map = {}
weight_array = []

ITERATIONS.times do |i|
	tilt_field_north(field)
	tilt_field_west(field)
	tilt_field_south(field)
	tilt_field_east(field)

	if cycle_start = field_map[field]
		# Found a cycle
		cycle_length = i - cycle_start
		pos = ((ITERATIONS-cycle_start) % cycle_length) - 1
		puts "Found cycle.  Iter: #{i} start: #{cycle_start} len: #{cycle_length} pos: #{pos} weight: #{weigh(field)}"
		puts "Part 2: #{weight_array[cycle_start+pos]}"
		break
	else
		# Take a deep copy of the field to use as the key in the hash
		field_copy = Marshal.load(Marshal.dump(field))
		field_map[field_copy] = i
		weight_array[i] = weigh(field)
	end
end

