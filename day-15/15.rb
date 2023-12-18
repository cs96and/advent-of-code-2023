def hash_func(str)
	str.each_char.reduce(0) { |sum, ch| ((sum + ch.ord) * 17) % 256 }
end

steps = File.read("../inputs/day-15/15.txt", chomp:true).split(',')

sum = steps.sum { hash_func(_1) }
puts "Part 1: #{sum}"

boxes = []
steps.each do |step|
	label, operation, amount = *step.split(/([-=])/)

	hash_value = hash_func(label)

	box = boxes[hash_value]
	box = (boxes[hash_value] = {}) if box.nil?

	case operation
	when '-'
		box.delete(label)
	when '='
		box[label] = amount.to_i
	end
end

sum = boxes.each.with_index(1).sum do |box, i|
	next 0 if box.nil?
	box.each.with_index(1).sum { |(key, value), j| i * j * value }
end

puts "Part 2: #{sum}"
