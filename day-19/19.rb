Part = Struct.new('Part', :x, :m, :a, :s) do
	def value
		return x + m + a + s
	end
end

Instruction = Struct.new('Instruction', :category, :op, :value, :dest) do
	def process(part)
		return dest if category.nil?
		return dest if part[category].send(op, value)
		return nil
	end
end

def accept_part?(part, workflows)
	wf = workflows['in']
	while true
		dest = do_workflow(part, wf)
		case dest
		when 'A'
			return true
		when 'R'
			return false
		else
			wf = workflows[dest]
		end
	end
end

def do_workflow(part, workflow)
	workflow.each do |instruction|
		if (dest = instruction.process(part))
			return dest
		end
	end
	raise "No matching instruction in workflow"
end


workflows = {}
parts = []

is_workflow = true
IO.foreach('../inputs/day-19/19.txt', chomp:true) do |line|
	if line.empty?
		is_workflow = false
		next
	end

	if is_workflow
		m = line.match(/(.*?)\{(.*)\}/)
		name = m[1]
		workflow_strings = m[2].split(',')
		workflows[name] = workflow_strings.map do |wf|
			m = wf.match(/(?:([xmas])([<>])(\d+):)?(\w+)/)
			Instruction.new(m[1]&.to_sym, m[2]&.to_sym, m[3]&.to_i, m[4])
		end
	else
		part = Part.new
		line.scan(/([xmas])=(\d+)/) do |category, value|
			part[category] = value.to_i
		end
		parts << part
	end
end

workflows.each { |k,v| puts "#{k} => #{v}" }
parts.each { puts _1 }

sum = 0
parts.each do |part|
	sum += part.value if accept_part?(part, workflows)
end

puts sum
