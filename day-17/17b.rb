#!/bin/env ruby

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

class PriorityQueue
	def initialize(cmp: nil)
		@a = []
		if (@cmp = cmp).nil?
			@cmp = Proc.new { _1 <=> _2 }
		end
	end

	def insert(obj)
		place = lower_bound_index(obj)
		@a.insert(place, obj)
	end

	def delete(obj)
		equal_range_index(obj).each do |i|
			return @a.delete_at(i) if @a[i] == obj
		end
	end

	def lower_bound_index(obj)
		@a.bsearch_index { |i| @cmp.call(obj,i) <= 0 } || @a.size
	end

	def lower_bound(obj)
		@a[lower_bound_index(obj)]
	end

	def upper_bound_index(obj)
		@a.bsearch_index { |i| @cmp.call(obj,i) < 0 } || @a.size
	end

	def upper_bound(obj)
		@a[upper_bound_index(obj)]
	end

	def equal_range_index(obj)
		(lower_bound_index(obj)...upper_bound_index(obj))
	end

	def equal_range(obj)
		@a[equal_range_index(obj)]
	end

	# Delegate unknown methods to the array
	def method_missing(name, *args, **kwargs, &block)
		begin
			@a.send(name, *args, **kwargs, &block)
		rescue
			super
		end
	end

	def to_s = @a.map(&:to_s).to_s
	def inspect = @a.map(&:inspect).inspect

	def pop_front(*args) = @a.shift(*args)
	def pop_back(*args) = @a.pop(*args)
end

class Cell
	include Comparable

	attr_reader :y, :x
	attr_accessor :g, :f, :parent

	def initialize(*args, g: Float::INFINITY, f: Float::INFINITY, parent: nil)
		case args
		in [Array]
			@y, @x = *args[0]
		in [Integer=>y, Integer=>x]
			@y = y
			@x = x
		end
		@g = g
		@f = f
		@parent = parent
	end

	def in_grid?(grid)
		@y >= 0 && @y < grid.size && @x >= 0 && @x < grid[0].size
	end

	def get_neighbours(grid)
		if !@parent.nil? && !same_times(3)
			dir = self - @parent
			nxt = Cell.new(coord(delta:dir), parent: self)
			return nxt.in_grid?(grid) ? [nxt] : []
		end

		neighbours = [
			Cell.new(coord(delta: [1,0]), parent: self),   # Down
			Cell.new(coord(delta: [0,1]), parent: self),   # Right
			Cell.new(coord(delta: [-1,0]), parent: self),  # Up
			Cell.new(coord(delta: [0,-1]), parent: self)   # Left
		]

		neighbours.reject do |n|
			(n.coord == @parent&.coord) || !n.in_grid?(grid) || n.same_times(10)
		end
	end

	def same_times(n)
		return false if @parent.nil?
		parent = @parent
		prev_dir = self - @parent
		n.times do
			return false if parent.parent.nil?
			return false if parent - parent.parent != prev_dir
			parent = parent.parent
		end
		return true
	end

	def distance(rhs)
		case rhs
		when Cell
			(rhs.y - @y).abs + (rhs.x - @x).abs
		when Array
			(rhs[0] - @y).abs + (rhs[1] - @x).abs
		end
	end

	def display_route(grid)
		route = {}
		node = self
		until node.nil?
			dir = node.parent.nil? ? nil : node - node.parent
			dir = case dir
			when [ 1, 0] then '⮟'
			when [-1, 0] then '⮝'
			when [ 0, 1] then '⮞'
			when [ 0,-1] then '⮜'
			else '.'
			end
			route[node.coord] = dir
			node = node.parent
		end
		grid.each_index do |row|
			puts grid[row].map.with_index { |ch, col| route[[row,col]]&.green || ch }.join
		end
	end

	def coord(delta: [0,0]) = [@y+delta[0],@x+delta[1]]

	def <=>(rhs) = coord <=> rhs.coord

	def -(rhs) = [@y-rhs.y, @x-rhs.x]

	def eql?(rhs) = self == rhs

	def hash = coord.hash

	def to_s = "[#{@y},#{@x}] g:#{g} f:#{f}"
end

def display_grid(grid)
	puts grid.map { |row| row.map(&:to_s).join }
end

def a_star(grid, start, goal)
	open_queue = PriorityQueue.new(cmp: Proc.new{_1.f <=> _2.f})
	open_queue.insert(Cell.new(start, g: 0, f:0))

	f_score = Hash.new(Float::INFINITY)
	
	until open_queue.empty?
		cell = open_queue.pop_front
		#puts "#{cell} - queue: #{open_queue}"
		if cell.coord == goal
			cell.display_route(grid)
			return cell.g
		end
 
		neighbours = cell.get_neighbours(grid)
		#puts "Neighs: #{neighbours.map(&:to_s).to_a}"
		neighbours.each do |n|
			#puts "#{cell} -> #{n}"
			g = cell.g + grid[n.y][n.x]
			f = g + n.distance(goal)
			# Need to keep track of the f score of this node with its 10 parents
			f_key = [	n,
						cell,
						cell.parent,
						cell.parent&.parent,
						cell.parent&.parent&.parent,
						cell.parent&.parent&.parent&.parent,
						cell.parent&.parent&.parent&.parent&.parent,
						cell.parent&.parent&.parent&.parent&.parent&.parent,
						cell.parent&.parent&.parent&.parent&.parent&.parent&.parent,
						cell.parent&.parent&.parent&.parent&.parent&.parent&.parent&.parent,
						cell.parent&.parent&.parent&.parent&.parent&.parent&.parent&.parent&.parent ]
			old_f = f_score[f_key]
			if f < old_f
				# This path to a neighbour is better than a previous one
				# Delete the previous version of the cell from the open queue if one is there
				n.f = old_f
				open_queue.delete(n)

				n.g = g
				n.f = g + n.distance(goal)
				f_score[f_key] = f
				open_queue.insert(n)
			end
		end
		#puts "new queue: #{open_queue}"
	end

	raise "No route found"
end

grid = IO.foreach('17.txt', chomp:true).map{ _1.chars.map(&:to_i) }
puts display_grid(grid)

cost = a_star(grid, [0,0], [grid.length-1, grid[0].length-1])
puts "Part 1: #{cost}"
