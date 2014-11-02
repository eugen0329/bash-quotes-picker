require "colorize"

module QuotesOutput
  def dispQuote(attr, content)
    puts "#{attr[:head]}".blue
    puts "#{content}"
    puts "♥ #{colorizeRating(attr[:rating])}\n\n"
  end

  def colorizeRating(rating)
    color = :default
    rating.to_i > 0 ? color = :green : color = :red
    "#{rating}".colorize(color)
  end

  module_function :colorizeRating, :dispQuote
end
