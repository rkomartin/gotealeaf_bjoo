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
    @deck.pop
  end
end

class Player
  attr_reader :name, :hand

  def initialize(name)
    @name = name
    @hand = []
  end

  def <<(new_card)
    @hand << new_card
  end

  def value
    @hand.size
  end
end

# Blackjack classes

class BJPlayer < Player
  BLACKJACK = 21

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

  def in_cards?
    self.value < BLACKJACK
  end

  def blackjack?
    self.value == BLACKJACK
  end

  def busted?
    self.value > BLACKJACK
  end
end

class BJDealer < BJPlayer
  DEALER_LIM = 17

  def in_cards?
    self.value < DEALER_LIM
  end
end

class BJGame
  def initialize(player_name, dealer_name)
    @player = BJPlayer.new(player_name)
    @dealer = BJDealer.new(dealer_name)
    @deck = Deck.new
  end

  def show
    puts "\n#{@player.name} has:"
    @player.hand.each {|c| puts c}
    puts "\n#{@dealer.name} has:"
    @dealer.hand.each {|c| puts c}
  end

  def start
    puts "\nDEALING FIRST TWO CARDS NOW:"
    @player << @deck.deal
    @dealer << @deck.deal
    @player << @deck.deal   
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

      new_card = @deck.deal
      puts "\nDealing to Player: #{new_card}"
      @player << new_card

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
      new_card = @deck.deal
      puts "\nDealing to Dealer: #{new_card}"
      @dealer << new_card

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
    player_total = @player.value
    dealer_total = @dealer.value

    if player_total > dealer_total
      puts "You win with #{player_total} against #{dealer_total}!"
    elsif player_total < dealer_total
      puts "Dealer wins with #{dealer_total} against #{player_total}."
    else
      puts "It's a tie at #{player_total}."
    end
  end

  def run
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
game.run
