module Asnica
  module StringEncoder
    extend self

    def sjisable(str)
      str = exchange(str,"U+301C", "U+FF5E") # wave-dash
      str = exchange(str,"U+2212", "U+FF0D") # full-width minus
      str = exchange(str,"U+00A2", "U+FFE0") # cent as currency
      str = exchange(str,"U+00A3", "U+FFE1") # lb(pound) as currency
      str = exchange(str,"U+00AC", "U+FFE2") # not in boolean algebra
      str = exchange(str,"U+2014", "U+2015") # hyphen
      str = exchange(str,"U+2016", "U+2225") # double vertical lines
    end

    def exchange(str,before_str,after_str)
      str.gsub(to_code(before_str).chr('UTF-8'),
                 to_code(after_str).chr('UTF-8') )
    end

    def to_code(str)
      return $1.to_i(16) if str =~ /U\+(\w+)/
      raise ArgumentError, "Invalid argument: #{str}"
    end
  end
end
