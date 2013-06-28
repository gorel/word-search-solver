# This class holds solution data for a word in a word search board
class Solution
  # Initialize a solution object for the given word.
  # Creation of the solution object specifies the (x,y)
  # origin point of the word, as well as the [dx, dy]
  # direction of the solution.
  def initialize(word, row, col, dx, dy)
    @word = word
    @row = row
    @col = col
    @dx = dx
    @dy = dy
  end
  
  def to_s
    "#{@word} at row #{@row}, column #{@col} with direction: #{get_direction}"
  end
  
private

  # Covert a [dx, dy] direction into a cardinal direction.
  # This is much easier for humans to read.
  def get_direction
    case @dx
    when -1
      case @dy
      when -1
        return "LEFT-UP DIAGONAL"
      when 0
        return "LEFT"
      when 1
        return "LEFT-DOWN DIAGONAL"
      end # case @dy
    when 0
      case @dy
      when -1
        return "UP"
      when 0
        # Invalid to have a [0,0] direction
        return "ERROR"
      when 1
        return "DOWN"
      end # case @dy
    when 1
      case @dy
      when -1
        return "RIGHT-UP DIAGONAL"
      when 0
        return "RIGHT"
      when 1
        return "RIGHT-DOWN DIAGONAL"
      end # case @dy
    end # case @dx
  end # def

end

# Class to solve a word search challenge
# Iterates through the keyword list, searching for it at each point on the graph,
# with each possible direction (LEFT, LEFT-UP DIAGONAL, UP, RIGHT-UP DIAGONAL, etc).
# When it finds a keyword, it creates a Solution object and moves to the next keyword
# Calling print solution will give a detailed list of where to find each word.
# It will also reprint the game board to visually show the user where each solution is.
class WordSearchSolver
  # Initialize a WordSearchSolver object with the given board and list of keywords
  def initialize(board, keywords, backwards = false)
    @board  = board
    @keywords = keywords
    
    # Get the number of rows and columns of the board    
    @rows = board.length
    @cols = board[0].length
    
    # These arrays correspond to the directions to search for a word (from a start point, search in the direction of X, Y)
    @x_dir = [0, 1]
    @y_dir = [0, 1]
    
    # If backwards searching is allowed, add reverse directions to the direction arrays
    if backwards
      @x_dir << -1
      @y_dir << -1
    end
    
    # Initialize the solutions array to hold data about found keywords
    @solutions = []
  end
  
  # Search for all keywords in the board
  def search_all
    # Delete keywords from the list as we find them
    @keywords.delete_if {|keyword| search(keyword)}
  end

  # Print out the solution to the board
  def print_solution
    puts
    
    # If any keywords were not located, warn the user
    if @keywords.size > 0
      puts "===WARNING==="
      puts "The following keyword(s) were not located:"
      @keywords.each {|keyword| puts keyword}
      puts
    end
    
    # TODO: Print out pretty solution ex: a t k-e-y-w-o-r-d x b
    @solutions.each {|soln| puts soln.to_s}
    # Print out what the board looks like to help the user see the solution
    puts
    print_board
  end
  
private
  
  # Print out the game board as given originally
  def print_board
    # Print out the column header
    print '   '
    (0...@cols).each {|n| print "#{n} "}
    puts 
    
    # For each row, print out that row with each character separated by a space
    @board.each_with_index do |row, index|
      puts "#{index}| #{row.join(' ')}"
    end
  end
  
  # Search for the given keyword within the board
  def search(keyword)
    # For each point on the board...
    (0...@rows).each do |row|
      (0...@cols).each do |col|
        # For each possible direction to search...
        @x_dir.each do |dx|
          @y_dir.each do |dy|
            # Search the board at that space in that direction
            if search_at(keyword, row, col, dx, dy)
              return true
            end # end if
          end # choose dy
        end # choose dx
      end # choose y
    end # choose x
    # NOTE: The word could not be found within the board!!
    return false
  end # end def
  
  # Check the board if the keyword exists at the given point with given direction
  def search_at(keyword, row, col, dx, dy)
    # If dx and dy are both zero, return -- null direction
    if dx == 0 and dy == 0
      return false
    end
    
    # Make copies of the initial location values so we know the origin if we find a match
    row_start = row
    col_start = col
    
    # For each character of the keyword
    keyword.chars.to_a.each_index do |index|
      # If we are out of the board boundary, we don't have a match
      if (row < 0 or col < 0 or row >= @rows or col >= @cols)
        return false
      end
      
      # If keyword[index] is not equal to that board space, we don't have a match
      if keyword[index] != @board[row][col]
        return false
      end
      
      # Increment the row and column by dy and dx
      row += dy
      col += dx
    end
    
    # At this point, we have made it to the end of our search and have a match
    @solutions << Solution.new(keyword, row_start, col_start, dx, dy)
    return true
  end
  
end

# Prompt the user for the input file location
def prompt
  # Get the filename from the user
  print "Please enter the location of the input file: "
  return gets.chomp
end

# Display an example board and word list
def display_help
  puts "a b c d g"
  puts "q o a f h"
  puts "d y t a g"
  puts "z e b r a"
  puts "a b n d p"
  puts "boy"
  puts "cat"
  puts "den"
  puts "gap"
  puts "tag"
  puts "zebra"
end

# Give the user the program directions
puts "I will solve a word search for you!  Create a text input file"
puts "with a game board followed by a list of words to obtain."
puts "Each letter of the board should be separated by a space."
puts "Type !help if you want an example."

# Prompt the user for the filename
filename = prompt

# If the user asked for an example, show the help text then prompt again
while filename == '!help'
  display_help
  filename = prompt
end

# Check if the game allows words to be backwards
print "Does the game allow words to be backwards? (y/n): "
allow_backwards = (gets.chomp.downcase == 'y' ? true : false)

# If the file cannot be located, abort with an error message
if not File.exists?(filename)
  abort "Error: File not found."
end

# Define the board variable which will be a 2D array
board = []

# Define the keywords variable which will hold the words 
keywords = []

# Read the file in, one line at a time
File.open(filename) do |file|
  file.each_line do |line|
    # If the line contains spaces, it must be part of the board
    if line.count(' ') > 0
      board << line.downcase.chomp.split(' ')
    # Otherwise, we have found a keyword
    else
      keywords << line.downcase.chomp
    end # end if
  end # end each_line
end # end File.open

# Create a WordSearchSolver
solver = WordSearchSolver.new(board, keywords, allow_backwards)

# Have the solver search for a solution
solver.search_all

# Print out the solver's solution
solver.print_solution
