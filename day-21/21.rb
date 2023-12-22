#!/bin/env ruby

def find_positions(garden, pos, steps, cache={}, i=0)
	return 0 if cache.include?([pos,i])

	if i == steps
		puts "Found position #{pos}"
		cache[[pos,i]] = 1
		return 1
	end

	count = 0
	neigh = get_neighbours(garden, pos)
	neigh.each do |n|
		count += find_positions(garden, n, steps, cache, i+1)
		cache[[pos,i]] = count
	end

	return count
end

def get_neighbours(garden, pos)
	neighbours = [
		[pos[0]-1, pos[1]],
		[pos[0]+1, pos[1]],
		[pos[0],   pos[1]-1],
		[pos[0],   pos[1]+1]
	]

	return neighbours.filter do |n|
		n[0] >= 0 && n[0] < garden.size && n[1] >= 0 && n[1] < garden[n[0]].size && garden[n[0]][n[1]] != '#'
	end
end

garden = IO.foreach('../inputs/day-21/21.txt', chomp:true).to_a
garden.each_with_index { |line, i| puts "#{i.to_s.rjust(2)} #{line}"}

start = nil
garden.each_with_index do |line, row|
	if col = line.index('S')
		start = [row,col]
		break
	end
end
puts start.to_s

raise "No start found" if start.nil?

count = find_positions(garden, start, 64)
puts count
