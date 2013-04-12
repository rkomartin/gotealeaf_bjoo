SUITS = %w[hearts spades clubs diamonds]
VALUES = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace]

BLACKJACK = 21
DEALER_LIM = 17

class Card
  attr_reader :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def to_s
    print "#{@value} of #{@suit}"
  end
end

class Deck
  def initialize
    @deck = []
    SUITS.each { |s| VALUES.each { |v| @deck << Card.new(s, v) }}
    @deck.shuffle!
  end

  def deal
    new_card = @deck.pop
    print "Dealing new card: "
    puts "#{new_card.to_s}"
    new_card
  end
end

class Player
  attr_reader :name

  def initialize(name)
    @name = name
    @hand = []
  end

  def <<(newcard)
    @hand << newcard
  end

  def show
    @hand.each {|c| puts c.to_s}
  end

  def hand_value
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

  def blackjack?
    self.hand_value == BLACKJACK ? true : false
  end

  def busted?
    self.hand_value > BLACKJACK ? true : false
  end
end

class Game
  def initialize(player_name)
    @player = Player.new(player_name)
    @dealer = Player.new("Dealer")
    @deck = Deck.new
  end

  def show
    puts "\n#{@player.name} has:"
    @player.show
    puts "\n#{@dealer.name} has"
    @dealer.show
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

    while @player.hand_value < BLACKJACK
      puts "\nYour move (Hit/Stay)"
      mv = gets.chomp

      if mv !~ /[hs]/i
        puts "\nWrong choice. Please choose again"
        next
      end

      if mv =~ /s/i
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

    while @dealer.hand_value < DEALER_LIM
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

end

puts "Welcome to Blackjack OO!"
print "Your name:"
player_name = gets.chomp

game = Game.new(player_name)
game.start
game.show

game.player_round
game.show

game.dealer_round
game.show

game.showdown
