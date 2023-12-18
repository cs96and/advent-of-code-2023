sum = 0

IO.foreach("../inputs/day-1/1.txt") do |line|
    first = line.index(/\d/)
    last = line.rindex(/\d/)
    sum += (line[first].to_i * 10) + line[last].to_i if !first.nil?
end

puts sum
