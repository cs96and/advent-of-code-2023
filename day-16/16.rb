#!/bin/env ruby
require 'set'

class Beam
	attr_accessor :x, :y, :move_y, :move_x
	def initialize(y, x, move_y, move_x)
		@y = y
		@x = x
		@move_y = move_y
		@move_x = move_x
	end

	def direction = [@move_y, @move_x]
	def up? = @move_y < 0
	def down? = @move_y > 0
	def left? = @move_x < 0
	def right? = @move_x > 0

	def move
		@y += @move_y
		@x += @move_x
		return self
	end

	def reverse
		@move_x *= -1
		@move_y *= -1
		self
	end

	def reflect_90
		@move_y, @move_x = @move_x, @move_y
		self
	end

	def reflect(mirror)
		res = case mirror
		when '\\'
			[reflect_90]
		when '/'
			[reflect_90.reverse]
		when '-'
			if up? || down?
				[ Beam.new(@y, @x, 0, -1), Beam.new(@y, @x, 0, 1) ]
			else
				[self]
			end
		when '|'
			if left? || right?
				[ Beam.new(@y, @x, -1, 0), Beam.new(@y, @x, 1, 0) ]
			else
				[self]
			end
		else
			[self]
		end
		return res
	end

	def to_s
		"[#{@y},#{x}] -> [#{@move_y},#{move_x}]"
	end
end

def traverse(grid, energy_grid, beam)
	# Check if beam has left the grid
	while (beam.y < grid.size && beam.y >= 0 && beam.x < grid[0].size && beam.x >= 0)
		# Check if we've already been over this square, in this direction
		return if energy_grid[beam.y][beam.x].include?(beam.direction)
		energy_grid[beam.y][beam.x] << beam.direction

		case grid[beam.y][beam.x]
		when '.'
			beam.move
		when '\\', '/'
			beam.reflect(grid[beam.y][beam.x])
			beam.move
		else
			new_beams = beam.reflect(grid[beam.y][beam.x])
			new_beams.each do
				traverse(grid, energy_grid, _1.move)
			end
		end
	end
end

def display_energy_grid(eg)
	eg.each do |row|
		puts row.map{ _1.size > 0 ? _1.size.to_s : '.'}.join
	end
end

def total_energy(eg)
	eg.sum { |row| row.sum { |point| point.empty? ? 0 : 1 } }
end

def reset_energy(rows, cols)
	Array.new(rows){ Array.new(cols){ Set.new } }
end

grid = IO.foreach("../inputs/day-16/16.txt", chomp:true).to_a
energy_grid = reset_energy(grid.size, grid[0].size)

puts grid
puts

traverse(grid, energy_grid, Beam.new(0, 0, 0, 1))
#display_energy_grid(energy_grid)
puts
puts "Part 1: #{total_energy(energy_grid)}"

max = 0
for y in (0...grid.size)
	for x in (0...grid[y].size)
		if [y, x] in [0, _]
			# Traverse down
			energy_grid = reset_energy(grid.size, grid[y].size)
			traverse(grid, energy_grid, Beam.new(y,x, 1, 0))
			max = [total_energy(energy_grid), max].max
		end

		if [y, x] in [_, 0]
			# Traverse right
			energy_grid = reset_energy(grid.size, grid[y].size)
			traverse(grid, energy_grid, Beam.new(y, x, 0, 1))
			max = [total_energy(energy_grid), max].max
		end

		if [y, x] in [^(grid.size-1), _]
			# Traverse up
			energy_grid = reset_energy(grid.size, grid[y].size)
			traverse(grid, energy_grid, Beam.new(y, x, -1, 0))
			max = [total_energy(energy_grid), max].max
		end

		if [y, x] in [_, ^(grid[y].size-1)]
			# Traverse left
			energy_grid = reset_energy(grid.size, grid[y].size)
			traverse(grid, energy_grid, Beam.new(y, x, 0, -1))
			max = [total_energy(energy_grid), max].max
		end
	end
end

puts "Part 2: #{max}"
