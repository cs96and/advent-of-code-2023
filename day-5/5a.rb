require 'set'

class RangedHash < Hash
	alias_method :old_lookup, :[]

	def [](key)
		self.each do |range, value|
			if range.include?(key)
				offset = key - range.first
				return value + offset
			end
		end
		return key
	end
end

seeds = Set.new()
seed_to_soil = RangedHash.new
soil_to_fertilizer = RangedHash.new
fertilizer_to_water = RangedHash.new
water_to_light = RangedHash.new
light_to_temperature = RangedHash.new
temperature_to_humidity = RangedHash.new
humidity_to_location = RangedHash.new
current_map = nil

sum = 0

IO.foreach("5.txt").each_with_index do |line, index|
	line.chomp!

	if line =~ /^seeds:/
		seeds = line.split(' ')[1..-1].map { |x| x.to_i }.to_set
	elsif line == "seed-to-soil map:"
		current_map = seed_to_soil
	elsif line == "soil-to-fertilizer map:"
		current_map = soil_to_fertilizer
	elsif line == "fertilizer-to-water map:"
		current_map = fertilizer_to_water
	elsif line == "water-to-light map:"
		current_map = water_to_light
	elsif line == "light-to-temperature map:"
		current_map = light_to_temperature
	elsif line == "temperature-to-humidity map:"
		current_map = temperature_to_humidity
	elsif line == "humidity-to-location map:"
		current_map = humidity_to_location
	elsif 0 != line.length
		dest, src, count = *line.split(' ').map { |x| x.to_i }
		current_map[src...src+count] = dest
	end
end

locations = []
seeds.each do |seed|
	soil = seed_to_soil[seed]
	fert = soil_to_fertilizer[soil]
	water = fertilizer_to_water[fert]
	light = water_to_light[water]
	temp = light_to_temperature[light]
	hum = temperature_to_humidity[temp]
	loc = humidity_to_location[hum]
	puts "Seed #{seed} Location #{loc}"
	locations << loc
end

puts "Min location = #{locations.min}"