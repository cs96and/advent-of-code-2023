require 'set'

class Point
	include Comparable

	attr_accessor :x, :y
	def initialize(x, y)
		@x = x
		@y = y
	end

	def <=>(rhs)
		[@y, @x] <=> [rhs.y, rhs.x]
	end

	def distance(rhs)
		(@x - rhs.x).abs + (@y - rhs.y).abs
	end

	def to_s
		"{#{@y}, #{@x}}"
	end

	def inspect
		to_s
	end
end

galaxy_map = IO.foreach("../inputs/day-11/11.txt", chomp: true).to_a

# Find columns with no galaxies
$empty_columns = []
(0...galaxy_map[0].length).each do |x|
	$empty_columns << x if galaxy_map.none? { |line| line[x] == '#' }
end

def calc_skipped_columns(x, scale)
	return 0 if x < $empty_columns[0]
	res = $empty_columns.bsearch_index { |i| i > x } || $empty_columns.size
	res * (scale-1)
end

puts "Empty columns #{$empty_columns}"

[2, 1000000].each_with_index do |scale, part|
	galaxy_set = Set.new()
	skipped_lines = 0
	galaxy_map.each_with_index do |line, y|
		if line.include?('#')
			line.each_char.with_index do |ch, x|
				galaxy_set << Point.new(x+calc_skipped_columns(x, scale), y+skipped_lines) if ch == '#'
			end
		else
			skipped_lines += scale-1
		end
	end

	sum = 0
	galaxy_set.each do |galaxy|
		galaxy_set.each do |other_galaxy|
			next if other_galaxy <= galaxy
			sum += galaxy.distance(other_galaxy)
		end
	end

	puts "Part #{part+1}: #{sum}"
end
