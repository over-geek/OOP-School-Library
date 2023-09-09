require './app'

class LibraryApp
  def initialize
    @app = App.new
  end

  def run
    puts 'Welcome to the OOP School Library App'
    puts

    loop do
      choice = display_menu

      case choice
      when 1 then @app.list_books
      when 2 then @app.list_people
      when 3 then @app.create_person
      when 4 then @app.create_book
      when 5 then @app.create_rental
      when 6 then list_rentals_for_person
      when 7 then exit_app
      else
        puts 'Please choose a number between 1 and 7'
      end
    end
  end

  private

  def display_menu
    puts 'Please select an option by entering its respective number'
    menu_options = {
      1 => 'List all books',
      2 => 'List all people',
      3 => 'Create a person',
      4 => 'Create a book',
      5 => 'Create a rental',
      6 => 'List all rentals for a given person id',
      7 => 'Exit'
    }

    menu_options.each do |index, string|
      puts "#{index} - #{string}"
    end

    gets.chomp.to_i
  end

  def list_rentals_for_person
    puts 'Enter person\'s id'
    person_id = gets.chomp.to_i
    @app.list_all_rentals(person_id)
  end

  def exit_app
    puts 'Thank you for using this app!'
    exit
  end
end

LibraryApp.new.run
