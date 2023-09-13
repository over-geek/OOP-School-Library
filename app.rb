require_relative 'person'
require_relative 'book'
require_relative 'rental'
require_relative 'student'
require_relative 'teacher'
require_relative 'classroom'
require_relative 'nameable'
require 'json'

class App
  DATA_DIR = 'data'.freeze

  def initialize
    @books = []
    @people = []
    @rentals = []

    load_books
    load_people
    load_rentals

    puts "Loaded Books: #{@books}"
    puts "Loaded People: #{@people}"
    puts "Loaded Rentals: #{@rentals}"
  end

  def list_all_books
    if @books.empty?
      puts 'There are no books available'
    else
      @books.each do |book|
        p "[Book] Title: #{book.title}, Author: #{book.author}"
      end
    end
  end

  def all_people_list
    people = []
    people.concat(Student.all)
    people.concat(Teacher.all)
    people
  end

  def list_all_people
    if @people.empty?
      puts 'There\'s no one here atm!'
    else
      @people.each do |person|
        if person.instance_of?(Student)
          p "[Student] Name: #{person.name}, ID: #{person.id}, Age: #{person.age}"
        else
          p "[Teacher] Name: #{person.name}, ID: #{person.id}, Age: #{person.age}"
        end
      end
    end
  end

  def create_a_person
    puts 'Are you a:'
    puts '1 - Student'
    puts '2 - Teacher'
    person_input = gets.chomp.to_i

    case person_input
    when 1 then create_a_student
    when 2 then create_a_teacher
    else
      raise 'Please enter a valid option, number 1 or 2'
    end
  end

  def create_a_student
    puts 'What is your name?'
    name = gets.chomp
    puts 'How old are you?'
    age = gets.chomp.to_i
    puts 'What grade are you?'
    classroom = gets.chomp
    puts 'Do you have your parents\' permission? [Y/N]'
    has_permission = gets.chomp
    permission = has_permission == 'y'
    student = Student.new(age, name, classroom, permission)
    @people << student
    puts 'Student successfully created'
    save_people
  end

  def create_a_teacher
    puts 'What is your name?'
    name = gets.chomp
    puts 'How old are you?'
    age = gets.chomp.to_i
    puts 'Enter your specialization'
    specialization = gets.chomp
    teacher = Teacher.new(age, specialization, true, name)
    @people << teacher
    puts 'Teacher Successfuly created'
    save_people
  end

  def create_a_book
    print 'Title: '
    title = gets.chomp
    print 'Author: '
    author = gets.chomp
    book = Book.new(title, author)
    @books << book
    p 'Book created sucessfully!'
    save_books
  end

  def create_a_rental
    return puts 'There are no books in the library.' if @books.empty?
    return puts 'There are no people in the system.' if @people.empty?

    book = select_book
    return puts 'Invalid book selection.' if book.nil?

    person = select_person
    return puts 'Invalid person selection.' if person.nil?

    print 'Date: '
    date = gets.chomp
    rental = Rental.new(date, person, book)
    @rentals << rental
    puts 'The book has been successfully rented!'
    save_rentals
  end

  def select_book
    puts 'Select a book by its number:'
    @books.each_with_index do |book, index|
      puts "Number: #{index + 1} - Title: #{book.title}, Author: #{book.author}"
    end
    book_id_input = gets.chomp.to_i
    return nil if book_id_input < 1 || book_id_input > @books.size

    @books[book_id_input - 1]
  end

  def select_person
    puts 'Select the person renting the book by their number:'
    @people.each_with_index do |person, index|
      puts "Number: #{index + 1} - Role: #{person.class.name}, Name: #{person.name}, ID: #{person.id}"
    end
    person_id_input = gets.chomp.to_i

    return nil if person_id_input < 1 || person_id_input > @people.size

    @people[person_id_input - 1]
  end

  def rental_person_id
    puts 'Enter ID of person: '
    person_id = gets.chomp.to_i
    rentals = @rentals.select { |rental| rental.person.id == person_id }
    if rentals.empty?
      puts 'No rentals found for the given person ID!'
    else
      rentals.each do |rental|
        puts "Date: #{rental.date}, Book: #{rental.book.title} by #{rental.book.author}"
      end
    end
  end

  def save_data(filename, data, &serialization_block)
    return unless data

    filepath = File.join(DATA_DIR, filename)
    serialized_data = data.map { |item| serialization_block.call(item) }
    File.open(filepath, 'w') do |file|
      JSON.dump(serialized_data, file)
    end
  end

  def load_data(filename, &deserialization_block)
    filepath = File.join(DATA_DIR, filename)
    return [] unless File.exist?(filepath)

    json_data = File.read(filepath)
    parsed_data = JSON.parse(json_data)
    parsed_data.map { |item_data| deserialization_block.call(item_data) }
  end

  def save_books
    save_data('books.json', @books) do |book|
      {
        'title' => book.title,
        'author' => book.author
      }
    end
  end

  def load_books
    @books = load_data('books.json') do |book_data|
      Book.new(book_data['title'], book_data['author'])
    end
  end

  def save_people
    save_data('people.json', @people) do |person|
      if person.instance_of?(Student)
        {
          'type' => 'Student',
          'name' => person.name,
          'age' => person.age,
          'classroom' => person.classroom,
          'permission' => person.permission
        }
      elsif person.instance_of?(Teacher)
        {
          'type' => 'Teacher',
          'name' => person.name,
          'age' => person.age,
          'specialization' => person.specialization
        }
      else
        {}
      end
    end
  end

  def load_people
    @people = load_data('people.json') do |person_data|
      case person_data['type']
      when 'Student'
        Student.new(
          person_data['age'],
          person_data['name'], person_data['classroom'],
          parent_permission: person_data['permission']
        )
      when 'Teacher'
        Teacher.new(person_data['name'], person_data['age'], person_data['specialization'])
      end
    end.compact || []
  end

  def save_rentals
    rental_data = @rentals.map do |rental|
      {
        'book_title' => rental.book.title,
        'person_id' => rental.person.id,
        'date' => rental.date
      }
    end

    save_data('rentals.json', rental_data) do |data|
      data
    end
  end

  def load_rentals
    @rentals = load_data('rentals.json') do |rental_data|
      book = find_book_by_title(rental_data['book_title'])
      person = find_person_by_id(rental_data['person_id'])
      Rental.new(rental_data['date'], person, book) if book && person
    end.compact || []
  end

  private

  def find_book_by_title(title)
    @books.find { |book| book.title == title }
  end

  def find_person_by_id(id)
    @people.find { |person| person.id == id }
  end
end
