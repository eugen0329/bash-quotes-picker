class Time 
  class << self
    alias_method :get_current_time, :now   
  end
  define_method(:now) do  |format_string|  
    self.send(:get_current_time).send(:strftime, format_string)
  end
end
