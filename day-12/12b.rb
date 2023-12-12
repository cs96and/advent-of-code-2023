class SpringRow
	def initialize(line, expand)
		@row, numbers = line.split(' ')
		@row = ((@row + '?') * expand).delete_suffix('?')
		@criteria = numbers.split(',').map(&:to_i) * expand
	end

	# I take no credit for this.  Completely stolen from, converted to ruby, and tweaked...
	# https://github.com/michaeljgallagher/Advent-of-Code/blob/b9a81e6dad859a7b4d30cc5637bfa750aaffb1b7/2023/12.py
	def count_permutations(pos=0, chunk=0, length=0, cache={})
		# If the current length > the current criteria length, then this is not a valid permutation
		if length > (@criteria[chunk] || 0)
			return 0
		# Have we reached the end of the row?
		elsif pos == @row.length
			# This is a valid permutation if...
			# We have already satisfied all the criteria  OR  we have just fulfilled the last criteria
			res = (chunk == @criteria.length) || ((chunk == @criteria.length - 1) && (@criteria.last == length))
			return res ? 1 : 0
		# Check if we have a cached result
		elsif cached_result = cache[[pos, chunk, length]]
			return cached_result
		end

		res = 0

		# Try the permutations if current position could be '#'
		if @row[pos] =~ /[#?]/
			res += count_permutations(pos+1, chunk, length+1, cache)
		end

		# Try the permutations if current position could be '.'
		if @row[pos] =~ /[.?]/
			if 0 == length
				# We've not found any '#' yet, just move along to the next char
				res += count_permutations(pos+1, chunk, 0, cache)
			elsif @criteria[chunk] == length
				# We've completed a chunk of the criteria, move onto the next one
				res += count_permutations(pos+1, chunk+1, 0, cache)
			#else
				# We didn't find enough '#' to fill the criteria for this chunk
			end
		end

		# Cache the result for this [pos,chunk,length]
		cache[[pos, chunk, length]] = res
		res
	end
end

[1,5].each_with_index do |expand, part|
	rows = IO.foreach("12.txt", chomp:true).map { |line| SpringRow.new(line, expand) }
	sum = rows.sum(&:count_permutations)
	puts "Part #{part+1}: #{sum}"
end
