#!/bin/env ruby

class String
	def colourize(rgb)
		"\e[38;2;#{rgb[0]};#{rgb[1]};#{rgb[2]}m#{self}\e[0m"
	end
end

def is_trench?(ch)
	case ch
	when '.', 'x', ' '
		return false
	else
		return true
	end
end

def is_corner?(grid, y, x)
	if 0 != y && is_trench?(grid[y-1][x])
		if 0 != x && is_trench?(grid[y][x-1])
			return 'J'
		elsif grid[y].length - 1 != x && is_trench?([y][x+1])
			return 'L'
		end
	elsif grid.length - 1 != y && is_trench?(grid[y+1][x])
		if 0 != x && is_trench?(grid[y][x-1])
			return '7'
		elsif grid[y].length - 1 != x && is_trench?(grid[y][x+1])
			return 'F'
		end
	end
	return nil
end

def count_inner(grid)
	# Scan diagonally
	count = 0
	grid.each_index do |start_y|
		row = grid[start_y]
		start_x = 0 == start_y ? 0 : grid[start_y].length - 1
		(start_x...grid[start_y].length).each do |x|
			inside = false
			y = start_y
			while (y < grid.length && x >= 0)
				case grid[y][x]
				when '.'
					if inside
						count += 1 if 
						grid[y][x] = 'x'
					else
						grid[y][x] = ' '
					end
				else
					count += 1
					# if this not a corner, or is an L or 7 corner, then we will swap inside/outside
					case is_corner?(grid, y, x)
					when 'L', '7', nil
						inside = !inside
					end
				end
				y += 1; x -= 1
			end
		end
	end
	return count
end

Instruction = Struct.new('Instruction', :direction, :distance, :rgb)

instructions = []
IO.foreach("../inputs/day-18/18.txt", chomp:true) do |line|
	m = line.match(/([LRUD])\s+(\d+)\s+\(#([0-9a-f]{6})\)/)
	rgb = m[3].scan(/../).map { _1.to_i(16) }
	instructions << Instruction.new(m[1], m[2].to_i, rgb)
end

# Pre-parse the instructions to calculate the needed grid size and starting point
y = x = min_y = min_x = max_y = max_x = 0
instructions.each do |inst|
	case inst.direction
	when 'D'
		y += inst.distance
		min_y = [y, min_y].min
		max_y = [y, max_y].max
	when 'U'
		y -= inst.distance
		min_y = [y, min_y].min
		max_y = [y, max_y].max
	when 'R'
		x += inst.distance
		min_x = [x, min_x].min
		max_x = [x, max_x].max
	when 'L'
		x -= inst.distance
		min_x = [x, min_x].min
		max_x = [x, max_x].max
	end
end

grid = Array.new((max_y - min_y) + 1) { Array.new((max_x - min_x) + 1, '.') }

y = min_y.abs
x = min_x.abs
grid[y][x] = '?'

instructions.each do |inst|
	case inst.direction
	when 'D'
		for i in (1..inst.distance)
			grid[y+i][x] = '#'.colourize(inst.rgb)
		end
		y += inst.distance
	when 'R'
		for i in (1..inst.distance)
			grid[y][x+i] = '#'.colourize(inst.rgb)
		end
		x += inst.distance
	when 'U'
		for i in (1..inst.distance)
			grid[y-i][x] = '#'.colourize(inst.rgb)
		end
		y -= inst.distance
	when 'L'
		for i in (1..inst.distance)
			grid[y][x-i] = '#'.colourize(inst.rgb)
		end
		x -= inst.distance
	end
end

puts grid.map.with_index { |ch,i| i.to_s.rjust(3) + ' ' + ch.join }
puts 
count = count_inner(grid)

puts grid.map.with_index { |ch,i| i.to_s.rjust(3) + ' ' + ch.join }

puts "Part 1: #{count}"
