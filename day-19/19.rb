#!/bin/env ruby

class String
	# colorization
	def colorize(color_code)
	  "\e[#{color_code}m#{self}\e[0m"
	end
  
	def green
		colorize(32)
	end
end

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

	def invert
		new_op = (op == :<) ? :>= : :<=
		Instruction.new(self.category, new_op, self.value, "")
	end

	def to_s
		if category.nil?
			return "#{dest}"
		else
			dest_str = dest.empty? ? "" : " -> #{dest}"
			return "#{category}#{op}#{value}#{dest_str}"
		end
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

def find_accept_paths(workflows, name='in', range_map=nil, depth=0)
	puts "#{'  '*depth}** #{name} **"

	range_map = { x: (1..4000), m: (1..4000), a: (1..4000), s: (1..4000) } if range_map.nil?

	count = 0
	workflow = workflows[name]
	workflow.each do |instruction|
		prev_range = range_map[instruction.category]
		if !instruction.category.nil?
			case instruction.op
			when :<
				range_map[instruction.category] = (prev_range.min..[prev_range.max,instruction.value-1].min)
			when :>
				range_map[instruction.category] = ([prev_range.min,instruction.value+1].max..prev_range.max)
			end
		end

		case instruction.dest
		when 'A'
			# Found an accept path
			path_sum = sum_range_map(range_map)
			count += path_sum

			puts "#{'  '*(depth+1)}#{range_map} => #{path_sum}".green
		when 'R'
			# Reject - do nothing
		else
			count += find_accept_paths(workflows, instruction.dest, range_map.dup, depth+1)
		end

		inv = instruction.invert
		if !inv.category.nil?
			case inv.op
			when :<=
				range_map[inv.category] = (prev_range.min..[prev_range.max,inv.value].min)
			when :>=
				range_map[inv.category] = ([prev_range.min,inv.value].max..prev_range.max)
			end
		end
	end
	return count
end

def sum_range_map(range_map)
	range_map.values.reduce(1) { |sum, range| sum *= range.count }
end

# Parse input file
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

#workflows.each { |k,v| puts "#{k} => #{v}" }
#parts.each { puts _1 }

part1 = parts.sum do |part|
	accept_part?(part, workflows) ? part.value : 0
end

combinations = find_accept_paths(workflows)

puts "Part 1: #{part1}"
puts "Part 2: #{combinations}"
