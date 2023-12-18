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
	def initialize(&block)
		@a = []
		if block_given?
			@cmp = block
		else
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

class Node
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

	def direction
		return parent.nil? ? nil : self - @parent
	end

	def distance_since_last_turn
		return 0 if @parent.nil?
		current_dir = direction()
		node = @parent
		count = 1
		while true
			return count if node.direction != current_dir
			count += 1
			node = node.parent
		end
	end

	def get_neighbours(grid, min_dist, max_dist)
		dist = distance_since_last_turn()
		if !@parent.nil? && dist < min_dist
			dir = self - @parent
			nxt = Node.new(coord(delta:dir), parent: self)
			return nxt.in_grid?(grid) ? [nxt] : []
		end

		neighbours = [
			Node.new(coord(delta: [1,0]), parent: self),   # Down
			Node.new(coord(delta: [0,1]), parent: self),   # Right
			Node.new(coord(delta: [-1,0]), parent: self),  # Up
			Node.new(coord(delta: [0,-1]), parent: self)   # Left
		]

		neighbours.reject do |n|
			(n.coord == @parent&.coord) || !n.in_grid?(grid) || n.distance_since_last_turn > max_dist
		end
	end

	def distance(rhs)
		case rhs
		when Node
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

def a_star(grid, start, goal, min_dist, max_dist)
	# Queue of open nodes, prioritized by f-score
	open_queue = PriorityQueue.new { _1.f <=> _2.f }
	open_queue.insert(Node.new(start, g: 0, f:0))

	f_score = Hash.new(Float::INFINITY)
	
	until open_queue.empty?
		node = open_queue.pop_front
		#puts "#{node} - queue: #{open_queue}"
		if node.coord == goal
			next if node.distance_since_last_turn < min_dist
			node.display_route(grid)
			return node.g
		end
 
		neighbours = node.get_neighbours(grid, min_dist, max_dist)
		neighbours.each do |n|
			g = node.g + grid[n.y][n.x]
			f = g + n.distance(goal)
			# Need to keep track of the f score of this node, its direction, and distance since last turn
			f_key = [n, n.direction, n.distance_since_last_turn]
			old_f = f_score[f_key]
			if f < old_f
				# This path to a neighbour is better than a previous one
				# Delete the previous version of the node from the open queue if one is there
				n.f = old_f
				open_queue.delete(n)

				n.g = g
				n.f = g + n.distance(goal)
				f_score[f_key] = f
				open_queue.insert(n)
			end
		end
	end

	raise "No route found"
end

grid = IO.foreach('../inputs/day-17/17.txt', chomp:true).map{ _1.chars.map(&:to_i) }
puts display_grid(grid)

start_node = [0, 0]
end_node = [grid.length-1, grid[0].length-1]

cost1 = a_star(grid, start_node, end_node, 0, 3)
puts "Part 1: #{cost1}"
puts

cost2 = a_star(grid, start_node, end_node, 4, 10)
puts "Part 2: #{cost2}"
