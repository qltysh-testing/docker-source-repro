# frozen_string_literal: true

class Calculator
  def power(base, exponent)
    base ** exponent
  end

  def square(number)
    number * number
  end

  def cube(number)
    number * number * number
  end

  def absolute(number)
    number.abs
  end
end
