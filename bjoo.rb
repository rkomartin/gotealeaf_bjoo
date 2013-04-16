# Generic card game classes

class Card
  attr_reader :value, :suit

  def initialize(value, suit)
    @value = value
    @suit = suit
  end

  def to_s
    "#{@value} of #{@suit}"
  end
end

class Deck
  SUITS = %w[hearts spades clubs diamonds]
  VALUES = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace]

  def initialize
    @deck = []
    SUITS.each { |s| VALUES.each { |v| @deck << Card.new(v, s) }}
    @deck.shuffle!
  end

  def deal
    new_card = @deck.pop
    puts "Dealing new card: #{new_card}"
    new_card
  end
end

class Hand
  def initialize
    @hand = []
  end

  def <<(newcard)
    @hand << newcard
  end

  def show
    @hand.each {|c| puts c}
  end

  def value
    @hand.size
  end
end

class Player
  attr_reader :name

  def initialize(name)
    @name = name
    @hand = Hand.new
  end

  def <<(new_card)
    @hand << new_card
  end

  def hand_show
    puts "\n#{@name} has:"
    @hand.show
  end

  def hand_value
    @hand.value
  end
end

# Blackjack classes

class BJHand < Hand
  def value
    arr = @hand.map{|c| c.value }
    total = 0

    arr.each do |value|
      if value == "Ace"
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end

    arr.select{|e| e == "Ace"}.count.times { total -= 10 if total > 21 }

    total
  end
end

class BJPlayer < Player
  BLACKJACK = 21

  def initialize(name)
    @name = name
    @hand = BJHand.new
  end

  def in_cards?
    self.hand_value < BLACKJACK
  end

  def blackjack?
    self.hand_value == BLACKJACK
  end

  def busted?
    self.hand_value > BLACKJACK
  end
end

class BJDealer < BJPlayer
  DEALER_LIM = 17

  def in_cards?
    self.hand_value < DEALER_LIM
  end
end

class BJGame
  def initialize(player_name, dealer_name)
    @player = BJPlayer.new(player_name)
    @dealer = BJDealer.new(dealer_name)
    @deck = Deck.new
  end

  def show
    @player.hand_show
    @dealer.hand_show
  end

  def start
    puts "\nDEALING FIRST TWO CARDS NOW:"
    puts "\nPlayer:"
    @player << @deck.deal
    @player << @deck.deal
    puts "\nDealer:"
    @dealer << @deck.deal   
    @dealer << @deck.deal
  end

  def player_round
    puts "\nPLAYER ROUND STARTING NOW:"

    if @player.blackjack?
      puts "Congratulations, you hit blackjack! You win!"
      exit
    end

    while @player.in_cards?
      puts "\nYour move (Hit/Stay)"
      mv = gets.chomp

      if mv !~ /[hs]/i
        puts "\nWrong choice. Please choose again"
        next
      elsif mv =~ /s/i
        puts "\nYou choose to stay"
        break
      end

      @player << @deck.deal

      if @player.blackjack?
        puts "\nCongratulations, you hit blackjack! You win!"
        exit
      elsif @player.busted?
        puts "\nSorry, it looks like you busted."
        exit
      end
    end
  end

  def dealer_round
    puts "\nDEALER ROUND STARTING NOW:"

    if @dealer.blackjack?
      puts "Sorry, dealer hits blackjack. You lose."
      exit
    end

    while @dealer.in_cards?
      @dealer << @deck.deal

      if @dealer.blackjack?
        puts "\nSorry, dealer hits blackjack. You lose."
        exit
      elsif @dealer.busted?
        puts "\nCongratulations, dealer busted! You win!"
        exit
      end
    end
  end

  def showdown
    puts "\nFINAL SHOWDOWN STARTING NOW:"
    player_total = @player.hand_value
    dealer_total = @dealer.hand_value

    if player_total > dealer_total
      puts "You win with #{player_total} against #{dealer_total}!"
    elsif player_total < dealer_total
      puts "Dealer wins with #{dealer_total} against #{player_total}."
    else
      puts "It's a tie at #{player_total}."
    end
  end

  def main
    start
    show
    player_round
    show
    dealer_round
    show
    showdown
  end
end

# App start

puts "Welcome to Blackjack OO!"
print "Your name:"
player_name = gets.chomp

game = BJGame.new(player_name, "Dealer")
game.main
