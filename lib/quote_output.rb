require "colorize"

module QuotesOutput
  def disp_quote(quote)
    puts "#{quote[:head]}".blue
    puts "#{quote[:content]}"
    puts "♥ #{colorize_rating(quote[:rating])}\n\n"
  end

  def colorize_rating(rating)
    color = :default
    rating.to_i > 0 ? color = :green : color = :red
    "#{rating}".colorize(color)
  end

  module_function :colorize_rating, :disp_quote
end
