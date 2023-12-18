#!/bin/env ruby

FILENAME = "18.txt"
DIRECTIONS = ['R', 'D', 'L', 'U']

Instruction = Struct.new('Instruction', :direction, :distance)
Vertex = Struct.new('Vertex', :x, :y)

def read_part1
	IO.foreach(FILENAME, chomp:true).map do |line|
		m = line.match(/([LRUD])\s+(\d+)\s+\(#(\w{6})\)/)
		Instruction.new(m[1], m[2].to_i)
	end
end

def read_part2
	instructions = []
	IO.foreach(FILENAME, chomp:true).map do |line|
		m = line.match(/.*\(#(\w{5})(\w)\)/)
		Instruction.new(DIRECTIONS[m[2].to_i], m[1].to_i(16))
	end
end

def get_vertices(instructions)
	vertices = [ Vertex.new(0, 0) ]

	circumference = 0
	instructions.each_with_index do |inst, i|
		circumference += inst.distance
		v = vertices[i].dup
		case inst.direction
		when 'D' then v.y += inst.distance
		when 'R' then v.x += inst.distance
		when 'U' then v.y -= inst.distance
		when 'L' then v.x -= inst.distance
		end
		vertices << v
	end

	return vertices, circumference
end

def calculate_area(instructions)
	vertices, circumference = get_vertices(instructions)

	# https://en.wikipedia.org/wiki/Shoelace_formula
	area = vertices.each_cons(2).sum do |(v0, v1)|
		#(v0.x * v1.y) - (v0.y * v1.x) # Triangle formula
		(v0.y + v1.y) * (v0.x - v1.x) # Trapezoid formula
	end
	return (area / 2) + (circumference / 2) + 1
end

area1 = calculate_area(read_part1)
area2 = calculate_area(read_part2)

puts "Part 1: #{area1}"
puts "Part 2: #{area2}"
