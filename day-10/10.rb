require 'set'

UP =    [-1, 0]
DOWN =  [1,  0]
LEFT =  [0, -1]
RIGHT = [0,  1]

def reverse_direction(direction)
	direction.map { |i|  i * -1 }
end

class Pipe
	@@char_map = { 'S' => 'S', ' ' => ' ', '-' => '━', '|' => '┃', '7' => '┓', 'J' => '┛', 'L' => '┗', 'F' => '┏'}
	@@char_map.default = '·'
	def initialize(ch)
		if ch.class <= String
			@ch = ch
		elsif ch.class <= Array
			ch = ch.sort
			case ch[0]
			when UP
				case ch[1]
				when DOWN then @ch = '|'
				when LEFT then @ch = 'J'
				when RIGHT then @ch = 'L'
				end
			when LEFT
				case ch[1]
				when RIGHT then @ch = '-'
				when DOWN then @ch = '7'
				end
			when RIGHT
				case ch[1]
				when DOWN then @ch = 'F'
				end
			end
		end
		if @ch.nil?
			raise "Invalid pipe #{ch}"
		end
	end

	def left?
		case @ch
		when '-', '7', 'J', 'S' then return true
		else return false
		end
	end

	def right?
		case @ch
		when '-', 'L', 'F', 'S' then return true
		else return false
		end
	end

	def up?
		case @ch
		when '|', 'J', 'L', 'S' then return true
		else return false
		end
	end

	def down?
		case @ch
		when '|', '7', 'F', 'S' then return true
		else return false
		end
	end

	def horizontal?
		left? || right?
	end

	def vertical?
		up? || down?
	end

	def corner?
		horizontal? && vertical?
	end

	def space?
		!horizontal? && !vertical?
	end

	def opposite?(prev)
		raise "Expected two corners" if !corner? || !prev.corner?
		return left? && prev.right? && up? == prev.down?
	end

	def clear
		@ch = ' '
	end

	def to_s
		@@char_map[@ch]
	end
end

class Maze
	def initialize(filename)
		@maze = []
		@loop_pipes = Set.new
		IO.foreach(filename, chomp: true).each_with_index do |line, index|
			@maze << line.each_char.map{ |c| Pipe.new(c) }
			if pos = line.index('S')
				@start = [index,pos]
			end
		end
	end

	def calc_direction(pos, prev_pos)
		#puts "pos = #{pos}, prev_pos = #{prev_pos}"
		# Calcluate which directions we can go, but don't go backwards
		y, x = *pos
		# Check if we can go left
		if x != 0 && @maze[y][x].left? && @maze[y][x-1].right? && [y, x-1] != prev_pos
			#puts "going left"
			@direction = LEFT
		# Check if we can go right
		elsif x < @maze[y].length - 1 && @maze[y][x].right? && @maze[y][x+1].left? && [y, x+1] != prev_pos
			#puts "going right"
			@direction = RIGHT
		# Check if we can go up
		elsif y != 0 && @maze[y][x].up? && @maze[y-1][x].down? && [y-1, x] != prev_pos
			#puts "going up"
			@direction = UP
		# Check if we can go down
		elsif y < @maze.length - 1 && @maze[y][x].down? && @maze[y+1][x] && [y+1, x] != prev_pos
			#puts "going down"
			@direction = DOWN
		else
			puts "nowhere to go"
			exit 1
		end
	end

	def loop_length
		prev_pos = nil
		pos = @start
		direction = initial_direction = calc_direction(pos, prev_pos)

		count = 0
		begin
			direction = calc_direction(pos, prev_pos)
			prev_pos = pos
			pos = [pos[0] + direction[0], pos[1] + direction[1]]
			@loop_pipes << pos
			count += 1
		end until pos == @start

		# Replace start character with correct pipe character
		@maze[@start[0]][@start[1]] = Pipe.new([initial_direction, reverse_direction(direction)])
		return count
	end

	def clear_non_loop
		0.upto(@maze.length - 1) do |y|
			0.upto(@maze[y].length - 1) do |x|
				@maze[y][x] = Pipe.new('.') if !@loop_pipes.include?([y,x])
			end
		end
	end

	def clear_outside
		count = 0
		0.upto(@maze.length - 1) do |y|
			inside_start = nil
			outside = -> { inside_start.nil? }
			inside = -> { !outside[] }
			enter_pipe = Pipe.new('|')
			0.upto(@maze[y].length - 1) do |x|
				pos = @maze[y][x]
				if pos.space?
					if outside[]
						pos.clear
					else
						count += 1
					end
				elsif pos.vertical?
					if !pos.horizontal? || (enter_pipe.vertical? && !enter_pipe.horizontal?)
						enter_pipe = pos
						inside_start = outside[] ? x : nil
					elsif !pos.opposite?(enter_pipe)
						enter_pipe = pos
						inside_start = outside[] ? x : nil
					elsif inside[]
						inside_start = x
					end
				end
				#puts "y=#{y} x=#{x} #{pos.to_s} #{outside[] ? 'outside' : 'inside'} count=#{count}"
			end
			if inside[]
				@maze[y][inside_start+1..-1].each {|pipe| count -= 1; pipe.clear}
			end
		end
		return count
	end

	def to_s
		i = -1
		@maze.reduce("") do |str, line|
			str += (i+=1).to_s.rjust(3) +
					line.reduce("") {|str2, pipe| str2 += pipe.to_s} +
					"\n"
		end
	end
end

maze = Maze.new("../inputs/day-10/10.txt")
puts maze.to_s
loop_length = maze.loop_length

maze.clear_non_loop
puts
puts maze.to_s

count = maze.clear_outside
puts
puts maze.to_s

puts
puts "Part 1: #{loop_length/2}"
puts "Part 2: #{count}"
