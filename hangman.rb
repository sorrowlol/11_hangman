# frozen_string_literal: true

require 'json'

class Hangman
  def initialize
    @dictionary = File.open('5desk.txt')
    @secret_word = ''
    @incorrect_letters = []
    @turn = 0
  end

  def picks_word
    @word = @dictionary.readlines.map { |i| i.chomp.length >= 5 && i.chomp.length ? i.chomp : ' ' }
    @word.delete(' ')
    @secret_word = @word[rand(@word.length)].split('')
  end

  def load_game
    puts "Welcome to Hangman! You loaded from last game saved!  You have #{6 - @incorrect_letters.length} lives left! Don't die!"
    puts @display.join(' ')
    puts "Your word has #{@secret_word.length} letters!"
    player_picks
  end

  # secret word
  def start_game
    picks_word
    @display = Array.new(@secret_word.length, '_')
    puts 'Welcome to Hangman! You have 6 guesses before you hang... make them count!'
    puts @display.join(' ')
    puts "Your word has #{@secret_word.length} letters!"
    player_picks
  end

  # choose a letter function
  def player_picks
    save if @turn >= 1
    load if @turn.zero?
    puts 'Choose any letter (case insensitive)'
    @letter_pick = gets.chomp.downcase

    # if letter already picked
    if @display.include?(@letter_pick)
      puts 'You already used this letter! Pick another one'
      player_picks
    # if letter included in word
    elsif @secret_word.include?(@letter_pick)
      @secret_word.each_with_index do |i, idx|
        @display[idx] = @letter_pick if i == @letter_pick
      end
      puts "nice! you got letter #{@letter_pick}"

    # if letter not included in word and pushes letter to incorrect array
    else
      @incorrect_letters.push(@letter_pick)
      puts "Lives left #{6 - @incorrect_letters.length} out of 6"
      # if 6 tries game over
      if @incorrect_letters.length == 6
        puts @display.join(' ')
        puts "Incorrect letters chosen: #{@incorrect_letters}"
        puts 'you lose!'
        puts "The word was #{@secret_word.join('')}"
        return
      end
    end

    @turn += 1
    puts @display.join(' ')

    # runs win or loops again back to choose a letter -> player_picks

    if win
      puts 'yay you win!'
      puts "the word was #{@secret_word.join('')}"
    else
      puts "Incorrect letters chosen: #{@incorrect_letters}"
      player_picks
    end
  end

  def win
    @display.join('') == @secret_word.join('')
  end

  def save
    puts 'Would you like to save the game and load later? (y/n)'
    player_sav = gets.chomp
    if player_sav == 'y'
      saved_hash = {
        s_secret_word: @secret_word,
        s_incorrect_letters: @incorrect_letters,
        s_display: @display,
        s_turn: @turn
      }
      File.open('saved_game.json', 'a') do |f|
        f.puts(saved_hash.to_json)
      end
    end
  end

  def load
    puts 'Would you like to load last saved game?'
    player_load = gets.chomp
    if player_load == 'y'
      load_file = File.read('saved_game.json')
      load_file = JSON.parse(load_file)
      @secret_word = load_file['s_secret_word']
      @incorrect_letters = load_file['s_incorrect_letters']
      @display = load_file['s_display']
      @turn = load_file['s_turn']
      load_game
    end
  end
end

a = Hangman.new
a.start_game
