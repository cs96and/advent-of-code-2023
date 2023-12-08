node_map = {}

instructions = nil
starting_nodes = []
File.open("8.txt") do |file|
	# Read first line and convert L => 0, R => 1
	instructions = file.readline.chomp.each_char.map { |ch| ch == 'L' ? 0 : 1}

	regex = /(\w+)\s*=\s*\((\w+),\s*(\w+)\)/

	file.each_line(chomp: true) do |line|
		next if line.empty?
		match = line.match(regex)
		node, left, right = *match[1...]
		node_map[node] = [left, right]

		starting_nodes << node if node.end_with?('A')
	end
end

# Work out how many steps to a Z node for each starting node
counts = []
starting_nodes.each do |node|
	count = 0
	ip = 0 # instruction pointer

	while !node.end_with?('Z')
		node = node_map[node][instructions[ip]]
		count += 1
		ip = (ip + 1) % instructions.size
	end
	
	counts << count
end

puts counts.to_s
puts counts.reduce(:lcm)
