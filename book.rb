class Book
  attr_accessor :title, :author, :rentals

  @all_books = []

  def initialize(title, author)
    @title = title
    @author = author
    @rentals = []
    self.class.all_books.push(self)
  end

  def to_json(*_args)
    {
      title: @title,
      author: @author
    }.to_json(*args)
  end

  def add_rental(rental)
    @rentals.push(rental) unless @rentals.include?(rental)
  end

  class << self
    attr_reader :all_books
  end

  def self.all
    @all_books
  end
end
