require 'rspec'
require './lib/board'
require './lib/ship'
require './lib/cell'
require './lib/player'
require './lib/game'
require 'pry'

RSpec.describe Game do
  describe "#initialize" do
    it 'exists' do
      game = Game.new
      expect(game).to be_an_instance_of(Game)
    end
  end
  describe "#print_start_message" do
    it 'displays start message' do
      game = Game.new
      expect { game.print_start_message }.to output("Welcome to BATTLESHIP\n" +
                                                    "Enter p to play. Enter q to quit.\n").to_stdout
    end
  end
  describe "#place_computer_ships" do
    it 'can place a computer ship' do
      # computer needs to pick a random coordinate,
      game = Game.new
      cruiser = Ship.new("Cruiser", 3)
      game.place_computer_ships(cruiser)
      require "pry"; binding.pry
      expect(game.computer_board.ships.include?(cruiser)).to eq(true)
    end
  end
  describe "#random_coordinate" do
    it 'can select a random coordinate' do
      game = Game.new
      random_coord = game.random_coordinate(game.computer_board)
      expect(game.player_board.cells[random_coord]).to be_an_instance_of(Cell)
    end
  end
end

# print_start_message method
# game_over? method (while game_over? == false, loop gameplay?)
# start method (Welcome to Battleship! Enter p => play, q => quit)
