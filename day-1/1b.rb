def get_digit(line, pos)
    case line[pos]
    when 'o'
        digit = 1
    when 't'
        digit = line[pos+1] == 'w' ? 2 : 3
    when 'f'
        digit = line[pos+1] == 'o' ? 4 : 5
    when 's'
        digit = line[pos+1] == 'i' ? 6 : 7
    when 'e'
        digit = 8
    when 'n'
        digit = 9
    when /\d/
        digit = line[pos].to_i
    end
end

sum = 0
regex = /one|two|three|four|five|six|seven|eight|nine|\d/

IO.foreach("../inputs/day-1/1.txt") do |line|
    first = line.index(regex)
    last = line.rindex(regex)
    if !first.nil?
        puts "#{line[first]} #{line[last]}"
        puts "#{get_digit(line, first)} #{get_digit(line, last)}"
        sum += (get_digit(line, first).to_i * 10) + get_digit(line, last)
    end
end

puts sum
