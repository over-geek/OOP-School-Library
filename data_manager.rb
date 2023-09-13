require 'json'

module DataManager
  DATA_DIR = 'data'.freeze

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
