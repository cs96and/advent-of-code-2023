class Sequence
	def initialize(line)
		@arrays = []
		@arrays << line.split(/\s+/).map { |i| i.to_i }

		until @arrays.last.all? { |i| i == 0 }
			@arrays << @arrays.last.each_cons(2).map { |a,b| b-a }
		end
	end

	def find_next
		@arrays.reduce(0) { |sum, a| sum + a.last }
	end

	def find_prev
		@arrays.reverse_each.reduce(0) { |sum, a| sum = a[0] - sum }
	end
end

part1_sum = part2_sum = 0
IO.foreach("9.txt", chomp: true).each do |line|
	seq = Sequence.new(line)
	part1_sum += seq.find_next
	part2_sum += seq.find_prev
end

puts "Part 1: #{part1_sum}"
puts "Part 2: #{part2_sum}"
