require './app'

class LibraryApp
  MENU_OPTIONS = {
    1 => { text: 'List all books', action: :list_books },
    2 => { text: 'List all people', action: :list_people },
    3 => { text: 'Create a person', action: :create_person },
    4 => { text: 'Create a book', action: :create_book },
    5 => { text: 'Create a rental', action: :create_rental },
    6 => { text: 'List all rentals for a given person id', action: :list_rentals_for_person },
    7 => { text: 'Exit', action: :exit_app }
  }.freeze

  def initialize
    @app = App.new
  end

  def run
    display_welcome_message

    loop do
      choice = display_menu
      process_choice(choice)
    end
  end

  private

  def display_welcome_message
    puts 'Welcome to the OOP School Library App'
    puts
  end

  def display_menu
    puts 'Please select an option by entering its respective number'
    list_menu_options
    gets.chomp.to_i
  end

  def list_menu_options
    MENU_OPTIONS.each do |index, option|
      puts "#{index} - #{option[:text]}"
    end
  end

  def process_choice(choice)
    selected_option = MENU_OPTIONS[choice]
    if selected_option
      send(selected_option[:action])
    else
      puts 'Please choose a number between 1 and 7'
    end
  end

  def list_books
    @app.list_books
  end

  def list_people
    @app.list_people
  end

  def create_person
    @app.create_person
  end

  def create_book
    @app.create_book
  end

  def create_rental
    @app.create_rental
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

  public

  def main
    run
  end
end

LibraryApp.new.main
