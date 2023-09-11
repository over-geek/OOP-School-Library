require './app'

class LibraryApp
  def initialize
    @app = App.new
  end

  def run
    display_welcome_message
  end

  private

  def display_welcome_message
    puts 'Welcome to the OOP School Library App'
    puts
  end
end

LibraryApp.new.main
