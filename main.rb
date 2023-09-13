require './app'
require './menu'
require_relative 'create_files'

class LibraryApp
  def initialize
    @app = App.new
    @menu = Menu.new(@app)
  end

  def run
    create_dir
    display_welcome_message
    @menu.run
  end

  private

  def display_welcome_message
    puts 'Welcome to the OOP School Library App'
    puts
  end
end

LibraryApp.new.run
