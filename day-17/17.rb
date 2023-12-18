#!/bin/env ruby

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
        equal_range_index(obj) do |i|
            return @a.delete_at(i) if @a[i] == obj
        end
    end

    def lower_bound_index(obj)
        place = @a.bsearch_index { |i| @cmp.call(obj,i) <= 0 }
        place = @a.size if place.nil?
        return place
    end

    def lower_bound(obj)
        @a[lower_bound_index(obj)]
    end

    def upper_bound_index(obj)
        place = @a.bsearch_index { |i| @cmp.call(obj,i) < 0 }
        place = @a.size if place.nil?
        return place
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

    def to_s = @a.map(&:to_s)
    def inspect = @a.inspect(&:inspect)

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

    def get_neighbours(max_y, max_x)
        neighbours =[
            Cell.new(coord(delta: [1,0])),   # Down
            Cell.new(coord(delta: [0,1])),   # Right
            Cell.new(coord(delta: [-1,0])),  # Up
            Cell.new(coord(delta: [0,-1]))   # Left
        ]

        neighbours.reject do |n|
            (@parent && n.coord == @parent.coord) || n.y < 0 || n.y >= max_y || n.x < 0 || n.x >= max_x
            # TODO: reject going forwards if we've gone in the same direction three times
        end
    end

    def distance(rhs)
        case rhs
        when Cell
            (rhs.y - @y).abs + (rhs.x - @x).abs
        when Array
            (rhs[0] - @y).abs + (rhs[1] - @x).abs
        end
    end

    def coord(delta: [0,0]) = [@y+delta[0],@x+delta[1]]

    def <=>(rhs) = coord <=> rhs.coord

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

    g_score = Hash.new(Float::INFINITY)
    f_score = Hash.new(Float::INFINITY)
    
    until open_queue.empty?
        cell = open_queue.pop_front
        puts "#{cell}, queue: #{open_queue.size}"
        return cell.g if cell.coord == goal
 
        neighbours = cell.get_neighbours(grid.length, grid[0].length)
        neighbours.each do |n|
            g = cell.g + grid[n.y][n.x]
            #puts "neigh: #{n.coord} g:#{g}"
            old_g = g_score[n]
            if g < old_g
                # This path to a neighbour is better than a previous one

                # Delete the previous version of the cell from the open queue if one is there
                n.g = old_g
                open_queue.delete(n)

                n.parent = cell
                n.g = g
                n.f = g + n.distance(goal)
                g_score[n] = g
                open_queue.insert(n)
            end
        end
    end
end

grid = IO.foreach('17-test.txt', chomp:true).map{ _1.chars.map(&:to_i) }
#puts display_grid(grid)

cost = a_star(grid, [0,0], [grid.length-1, grid[0].length-1])
puts "Part 1: #{cost}"
