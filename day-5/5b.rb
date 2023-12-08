require 'set'

class RangedHash < Hash
	alias_method :old_lookup, :[]
	attr_accessor :name

	def initialize(hash, name)
		hash.sort.each do |key, value|
			self[key] = value
		end
		@name = name
	end

	def [](key)
		self.each do |source, target_range|
			if key < source
				return key...source
			elsif key < source + target_range.size
				offset = key - source
				return target_range.first+offset...target_range.max+1
			end
		end
		return key...Float::INFINITY
	end
end

seeds = []
seed_to_soil = {}
soil_to_fertilizer = {}
fertilizer_to_water = {}
water_to_light = {}
light_to_temperature = {}
temperature_to_humidity = {}
humidity_to_location = {}
current_map = nil

IO.foreach("5.txt").each_with_index do |line, index|
	line.chomp!

	if line =~ /^seeds:/
		s = line.split(' ')[1..-1].map { |x| x.to_i }
		s.each_slice(2) do |seed, length|
			seeds << (seed...seed+length)
		end
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
		current_map[src] = dest...dest+count
	end
end

seed_to_soil = RangedHash.new(seed_to_soil, "seed-to-soil")
soil_to_fertilizer = RangedHash.new(soil_to_fertilizer, "soil-to-fertilizer")
fertilizer_to_water = RangedHash.new(fertilizer_to_water, "fertilizer-to-water")
water_to_light = RangedHash.new(water_to_light, "water-to-light")
light_to_temperature = RangedHash.new(light_to_temperature, "light-to-temperature")
temperature_to_humidity = RangedHash.new(temperature_to_humidity, "temperature-to-humidity")
humidity_to_location = RangedHash.new(humidity_to_location, "humidity-to-location")

def source_to_target(map, source_range)
	result = []
	range_size_remaining = source_range.size
	i = source_range.first
	while range_size > 0
		target_range = map[i]
		if target_range.size > range_size_remaining
			target_range = target_range.first...target_range.first+range_size_remaining
		end
		result << target_range
		i += target_range.size
		range_size_remaining -= target_range.size
	end
	return result
end

all_maps = [ seed_to_soil, soil_to_fertilizer, fertilizer_to_water, water_to_light, light_to_temperature, temperature_to_humidity, humidity_to_location ]

source_ranges = seeds
all_maps.each do |map|
	#puts "\n#{map.name}:"
	#puts "Source ranges: #{source_ranges}"
	target_ranges = []
	source_ranges.each do |range|
		target_ranges += source_to_target(map, range)
	end
	#puts "Target ranges: #{target_ranges}"
	source_ranges = target_ranges
end

locations = source_ranges.map { |r| r.first }

puts "Min location = #{locations.min}"
