#!/bin/env ruby

class FlipFlop
	attr_reader :name, :state

	def initialize(name)
		@name = name
		@state = false
	end

	def reset
		@state = false
	end

	def process_pulse(src, pulse)
		# Only process low pulses
		return nil if :high == pulse
		@state = !@state
		return @state ? :high : :low
	end

	def inspect
		"FF(#{@name} #{@state ? 'ON' : 'off'})"
	end
end

class Conjunction
	attr_reader :name

	def initialize(name)
		@name = name
		@inputs = {}
	end

	def add_input(name)
		@inputs[name] = :low
	end

	def reset
		@inputs.keys.each { |key| @inputs[key] = :low }
	end

	def process_pulse(src, pulse)
		raise "No inputs configured for Conjunction #{@name}, but pulse received" if @inputs.empty?
		@inputs[src] = pulse
		return @inputs.values.all?(:high) ? :low : :high
	end

	def inspect
		"Con(#{@name} #{@inputs})"
	end
end

def push_the_button(parts, cables)
	low_count = 1
	high_count = 0

	queue = []
	cables["broadcaster"].each do |dest|
		queue << ["broadcaster", :low, dest]
		low_count += 1
	end

	until queue.empty?
		src, pulse, dest = *queue.shift
		#puts "#{src} -#{pulse}-> #{dest}"

		part = parts[dest]
		if !part.nil?
			out_pulse = part.process_pulse(src, pulse)
			if out_pulse
				out_dests = cables[dest]
				out_dests.each do |out_dest|
					yield dest, out_pulse, out_dest if block_given?

					queue << [dest, out_pulse, out_dest]
					if :low == out_pulse
						low_count += 1
					else
						high_count += 1
					end
				end
			end
		end
	end
	return low_count, high_count
end


parts = {}
cables = {}

IO.foreach('../inputs/day-20/20.txt', chomp:true) do |line|
	m = line.match(/([%&]?\w+)\s+->\s+(.*)/)
	src = m[1]
	dests = m[2].split(', ')

	skip = 1
	case src[0]
	when '%'
		parts[src[skip..]] = FlipFlop.new(src[skip..])
	when '&'
		parts[src[skip..]] = Conjunction.new(src[skip..])
	else
		skip = 0
	end

	cables[src[skip..]] = dests
end

# Tell each conjuction about its inputs
cables.each do |src, dests|
	dests.each do |dest|
		part = parts[dest]
		if Conjunction === part
			part.add_input(src)
		end
	end
end

puts "Parts: #{parts}\n\nCables: #{cables}\n"

low_total = high_total = 0
1000.times do
	low, high = push_the_button(parts, cables)
	low_total += low
	high_total += high
end

puts "\nPart 1: Low: #{low_total} High:#{high_total}  Total: #{low_total * high_total}"

parts.values.each { |part| part.reset }

# Find the part that points to rx
rx_parent = cables.each do |src, dests|
	break src if dests.include?("rx")
end

# Then find all the parts that output to that node
cycle_hash = {}
cables.each do |src, dests|
	cycle_hash[src] = 0 if dests.include?(rx_parent)
end

i = 1
while true
	push_the_button(parts, cables) do |src, pulse, dest|
		# Once all the parts that send to rx's parent send a high signal, then rx will receive a low signal
		if pulse == :high
			if val = cycle_hash[src]
				puts "#{i.to_s.rjust(5)} #{src} -#{pulse}-> #{dest}"
				cycle_hash[src] = i if val == 0
				if cycle_hash.values.none?(0)
					puts "Part 2: #{cycle_hash.values.reduce(&:lcm)}"
					return
				end
			end
		end
	end
	i += 1
end
