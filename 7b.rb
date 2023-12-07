
class Hand
	@@card_ranks = { 'J' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9,
					 'T' => 10, 'Q' => 12, 'K' => 13, 'A' => 14 }

	attr_accessor :orig_hand

	def initialize(str)
		@orig_hand = str.chars.map { |c| @@card_ranks[c] }
		@hand = Hash.new(0)

		str.chars.sort_by { |c| @@card_ranks[c] }.reverse.each do |c|
			@hand[@@card_ranks[c]] += 1
		end

		num_jokers = @hand.fetch(0, 0)

		# Sort hand by number per card, then card value (both descending)
		@hand = @hand.sort_by { |card, ammount| [-ammount, -card] }

		if num_jokers > 0 && num_jokers < 5
			# Remove the jokers, then add them onto the card that has the most amount,
			@hand.filter! { |c| c[0] != 0 }
			@hand[0][1] += num_jokers
		end
	end

	def rank
		case @hand.size
		when 1
			return 7		# Five of a kind
		when 2
			case @hand[0][1]
			when 1, 4
				return 6	# Four of a kind
			else
				return 5	# Full house
			end
		when 3
			if @hand.find { |c| c[1] == 3 }
				return 4	# Three of kind
			else
				return 3	# Two Pair
			end
		when 4
			return 2
		else
			return 1
		end
	end

	def <=>(rhs)
		result = self.rank <=> rhs.rank
		if 0 == result
			return @orig_hand <=> rhs.orig_hand
		else
			return result
		end
	end

	def to_s
		"#{@hand.to_s} (Rank: #{self.rank})"
	end
end

hands = []
IO.foreach("7.txt").each_with_index do |line, index|
	hand, bet = line.chomp.split(' ')
	hands << [ Hand.new(hand), bet.to_i ]
end

hands.sort_by! { |h| h[0] }

sum = 0
hands.each_with_index do |h, i|
	bet = h[1]
	puts "Hand #{i+1}: #{h[0].orig_hand}  Rank #{h[0].rank} Bet #{bet}"
	sum += h[1] * (i+1)
end
puts sum
