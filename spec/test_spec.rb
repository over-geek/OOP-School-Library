# spec/book_spec.rb

require_relative '../classes/book' # Update the path as needed
require_relative '../classes/rental' # Include any other dependencies

describe Book do
  let(:book) { Book.new(1, 'Sample Title', 'Sample Author') }

  describe '#initialize' do
    it 'initializes a new book with the provided attributes' do
      expect(book.id).to eq(1)
      expect(book.title).to eq('Sample Title')
      expect(book.author).to eq('Sample Author')
      expect(book.rentals).to be_empty
    end
  end

  describe '#to_json' do
    it 'returns a JSON representation of the book' do
      json_data = book.to_json
      expect(json_data).to include_json(
        id: 1,
        title: 'Sample Title',
        author: 'Sample Author',
        rentals: []
      )
    end
  end

  describe '#new_rental' do
    it 'adds a new rental to the book' do
      rental = Rental.new(1, book, nil, '2023-09-15')
      book.new_rental(rental)

      expect(book.rentals).to include(rental)
      expect(rental.book).to eq(book)
    end
  end
end
