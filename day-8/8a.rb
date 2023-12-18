
node_map = {}

instructions = nil
File.open("../inputs/day-8/8.txt") do |file|
	# Read first line and convert L => 0, R => 1
	instructions = file.readline.chomp.each_char.map { |ch| ch == 'L' ? 0 : 1}

	regex = /([A-Z]+)\s*=\s*\(([A-Z]+),\s*([A-Z]+)\)/

	file.each_line(chomp: true) do |line|
		next if line.empty?
		match = line.match(regex)
		node, left, right = *match[1...]
		node_map[node] = [left, right]
	end
end

ip = 0 # instruction pointer
count = 0
node = "AAA"

while node != "ZZZ"
	puts node
	node = node_map[node][instructions[ip]]
	count += 1
	ip = (ip + 1) % instructions.size
end

puts node
puts count
