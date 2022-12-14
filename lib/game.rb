require './lib/board'
require './lib/ship'
require './lib/cell'

class Game
  attr_reader :computer_board, :player_board
  def initialize
    @computer_board = Board.new
    @player_board = Board.new
  end

  def start
    self.print_start_message
    user_input = gets.chomp
    if user_input == "p"
      self.setup_game
      self.run_game
    elsif user_input == "q"
      puts "Exiting Program..."
    else
      puts "Invalid entry, please try again"
      self.start
    end
  end

  def setup_game
    @computer_board = Board.new
    @player_board = Board.new
    self.options_menu
    cruiser = Ship.new("Cruiser", 3)
    self.place_computer_ships(cruiser)
    submarine = Ship.new("Submarine", 2)
    self.place_computer_ships(submarine)
    self.place_player_ships
  end

  def options_menu
    puts "Would you like to customize board size? (Y/N)"
    option = gets.chomp
    if option.downcase == "y"
      rows = self.get_board_rows
      columns = self.get_board_columns
      @player_board.customize_board_size(columns, rows)
      @computer_board.customize_board_size(columns, rows)
    elsif option.downcase != "n"
      puts "Invalid entry, please try again"
      self.options_menu
    end
  end

  def get_board_rows
    puts "Enter number of board rows (between 4 - 10):"
    rows = gets.chomp.to_i
    if rows < 4 || rows > 10
      puts "Invalid entry, number of rows can be between 4 and 10"
      rows = self.get_board_rows
    end
    rows
  end

  def get_board_columns
    entry_valid = false
    #which validation method is better between this and get_board_rows
    until entry_valid == true
      puts "Enter number of board columns (between 4 - 10):"
      columns = gets.chomp.to_i
      if columns < 4 || columns > 10
        puts "Invalid entry, number of columns can be between 4 and 10"
      else
        entry_valid = true
      end
    end
    columns
  end

  def run_game
    play_again = nil

    until play_again == false
      until self.game_over?
        self.display_game_boards
        self.player_shot
        self.intelligent_shot
      end

      puts "Play again? (Y/N)"
      restart_input = gets.chomp
      if restart_input.downcase == "y"
        play_again = true
        self.setup_game
      else
        puts "Exiting Program..."
        play_again = false
      end
    end
  end

  def print_start_message
    puts "Welcome to BATTLESHIP\n" + "Enter p to play. Enter q to quit."
  end

  def random_coordinate(board)
    board.cells.keys.sample
  end


  # def random_adjacent_coords(start_coord, length)
  #   up = [start_coord]
  #   down = [start_coord]
  #   left = [start_coord]
  #   right = [start_coord]
  #   increment = 1
  #   length.times do
  #     up << (start_coord[0].ord - increment).chr + start_coord[1]
  #     down << (start_coord[0].ord + increment).chr + start_coord[1]
  #     left << start_coord[0] + (tart_coord[1] + increment)
  #     right <<
  #     increment += 1
  #   end
  # end

  def computer_ship_coordinates(ship)
   comp_coordinates = @computer_board.cells.keys.sample(ship.length)
   until @computer_board.valid_placement?(ship, comp_coordinates) == true
     comp_coordinates = @computer_board.cells.keys.sample(ship.length)
   end
   comp_coordinates
  end

  def place_computer_ships(ship)
    @computer_board.place(ship, computer_ship_coordinates(ship))
  end

  def random_shot
    computer_fire = @player_board.cells.keys.sample

    until @player_board.cells[computer_fire].fired_upon? == false
      computer_fire = @player_board.cells.keys.sample
    end
    @player_board.cells[computer_fire].fire_upon
    self.display_results(computer_fire, @player_board)
    computer_fire
  end

  def display_game_boards
    puts "=============COMPUTER BOARD============= \n"
    puts @computer_board.render
    puts "==============PLAYER BOARD============== \n"
    puts @player_board.render(true)
    puts "======================================== \n"
  end


  def place_player_ships
    puts "I have laid out my ships on the grid.\n" +
         "You now need to lay out your two ships.\n"+
         "The Cruiser is three units long and the Submarine is two units long.\n" +
         @player_board.render +
         "Enter the squares for the Cruiser (3 spaces):\n"
    cruiser = Ship.new("Cruiser", 3)
    cruiser_placed = false
    while cruiser_placed == false
      cruiser_input = gets.chomp.split(" ").map(&:strip)
      if @player_board.valid_placement?(cruiser, cruiser_input)
        @player_board.place(cruiser, cruiser_input)
        cruiser_placed = true
      else
        puts "Those are invalid coordinates. Please try again:"
      end
    end

    puts @player_board.render(true)

    puts "Enter the squares for the Submarine (2 spaces):"
    submarine = Ship.new("Submarine", 2)
    sub_placed = false
    until sub_placed == true
      sub_input = gets.chomp.split(" ").map(&:strip)
      if @player_board.valid_placement?(submarine, sub_input)
        @player_board.place(submarine, sub_input)
        sub_placed = true
      else
        puts "Those are invalid coordinates. Please try again:"
      end
    end
  end

  def player_shot
    puts "Enter the coordinate for your shot:"
    valid_shot = false
    until valid_shot == true
      shot_input = gets.chomp
      if @computer_board.valid_coordinate?(shot_input) && @computer_board.cells[shot_input].fired_upon? == false
        @computer_board.cells[shot_input].fire_upon
        valid_shot = true
        self.display_results(shot_input, @computer_board)
      elsif @computer_board.valid_coordinate?(shot_input) && @computer_board.cells[shot_input].fired_upon?
        puts "Coordinate has already been fired upon, enter another coordinate:"
      else
        puts "Please enter a valid coordinate:"
      end
    end
  end

  def display_results(shot, board)
    if board == @computer_board
      if @computer_board.cells[shot].empty?
        result = "was a miss."
      elsif @computer_board.cells[shot].ship.sunk?
        result = "sunk a ship!"
      else
        result = "was a hit."
      end
      puts "Your shot on #{shot} #{result}"

    elsif board == @player_board
      if @player_board.cells[shot].empty?
        result = "was a miss."
      elsif @player_board.cells[shot].ship.sunk?
        result = "sunk a ship!"
      else
        result = "was a hit."
      end
      puts "My shot on #{shot} #{result}"
    end
  end

  def game_over?
    self.display_game_over_message
    self.computer_lost? || self.player_lost?
  end

  def computer_lost?
    @computer_board.ships.all? {|ship| ship.sunk?}
  end

  def player_lost?
    @player_board.ships.all? {|ship| ship.sunk?}
  end

  def display_game_over_message
    if self.computer_lost?
      self.display_game_boards
      puts "You won!"
    elsif self.player_lost?
      self.display_game_boards
      puts "I won!"
    end
  end
  # B2 is starting coordinate, up should be A2, down should be C2, left should be
  # B1, right should be B3

  def find_adjacent_coords(start_coord)
    adjacent_coordinates = [
      (start_coord[0].ord - 1).chr + start_coord[1],
      (start_coord[0].ord + 1).chr + start_coord[1],
      start_coord[0] + (start_coord[1].ord - 1).chr,
      start_coord[0] + (start_coord[1].ord + 1).chr
    ]
    adjacent_coordinates.delete_if do |adjacent_coordinate|
      @player_board.valid_coordinate?(adjacent_coordinate) == false
    end
    # require 'pry'; binding.pry
    adjacent_coordinates
  end

  def unsunk_ships
    board_hits = @player_board.cells.keys.find_all do |key|
      cell = @player_board.cells[key]
      cell.fired_upon? && cell.ship != nil && cell.ship.sunk? == false
    end
    board_hits
  end

  def intelligent_shot
    if unsunk_ships == []
      return random_shot
    end

    potential_targets = self.unsunk_ships.map {|coordinate| find_adjacent_coords(coordinate)}
    potential_targets.flatten!
    educated_guess = potential_targets.sample
    until @player_board.cells[educated_guess].fired_upon? == false
      educated_guess = potential_targets.sample
    end
    @player_board.cells[educated_guess].fire_upon
    self.display_results(educated_guess, @player_board)
    educated_guess
  end

end
