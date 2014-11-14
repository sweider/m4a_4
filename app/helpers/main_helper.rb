module MainHelper

  class Equation1
    attr_accessor :c, :c1, :c2

    def initialize(c, ua, ub, a, b)
      @c = c;
      @c1 = (4 * c * (ub - ua) - 5 * ( Math.sin(2 * b) - Math.sin(2 * a))) / (4 * (Math.sin(a) - Math.sin(b)))
      @c2 = ua - 1 / c * (5/4 * Math.sin(2 * a) + a - c1 * Math.sin(a))
    end

    def calculate(x)
      (1 / self.c) * (5 / 4 * Math.sin(2 * x) + x - self.c1 * Math.sin(x)) + self.c2
    end

    def calculateInRangeWithStep(range, step)
      result = []
      range.step(step).each { |currentX| result << self.calculate(currentX) }
      result
    end
  end

  class Equation2
    attr_accessor :c, :c1, :c2

    def initialize(c, ua, ub, a, b)
      @c = c
      @c1 = (((ub - ua) - 5 / c * (b - a)) * c) / (var(b) - var(a))
      @c2 = ua - 5 / c * a + c1 / c * var(a)
    end

    def calculate(x)
      5 / self.c * x - self.c1 / self.c * var(x)
    end

    def calculateInRangeWithStep(range, step)
      result = []
      range.step(step).each { |currentX| result << self.calculate(currentX) }
      result
    end

    private
    def get_log_variable(x)
      Math.log((Math.sin(x / 2) + Math.cos(x / 2)) / (Math.cos(x/2) - Math.sin(x / 2)))
    end
    alias var get_log_variable
  end

  class Function
    def initialize(function)
      @func = function
    end

    def getValuesInRangeWithStep(range, step)
      result = []
      range.step(step).each { |currentX| result << @func.call(currentX) }
      result
    end
  end

  class Lab1Task2Solver
    def initialize(steps_count,a,ua,b,ub, qx, px, fx)
      @a = a #0
      @b = b # 1.5
      @ua = ua # 5
      @ub = ub #0
      @steps_count = steps_count
      @h = 1, @m = [], @n = [], @c = [], @d = [], @y = []
      @qx = qx; @px = px; @fx = fx;
      self.initialize_coefficients_arrays
    end

    def double_steps_count!
      @steps_count *= 2
      self.initialize_coefficients_arrays
      self
    end

    def solve
      @y[@steps_count - 1] = @ub
      (@steps_count - 2).downto(1).each { |i|
        @y[i] = @c[i] * (@d[i] - @y[i + 1])
      }
      @y[0] = @ua
      {step: @h, y: @y}
    end

    protected
    def initialize_coefficients_arrays
      @h = (@b - @a).to_f / @steps_count
      @m = [@steps_count]
      @n = [@steps_count]
      @c = [@steps_count]
      @d = [@steps_count]
      @y = [@steps_count]

      (0..(@steps_count - 1)).each do |i|
        x = X(i)
        pi = @px.call(x)
        @m[i] = (2 * @qx.call(x) * @h**2 - 4) / (2 + @h * pi)
        @n[i] = (2 - @h * pi) / (2 + @h * pi)

        if (i > 1)
          @c[i] = 1 / (@m[i] - @n[i] * @c[i - 1])
          @d[i] = (2 * @fx.call(x) * @h**2) / (2 + @h * pi) - @n[i] * @c[i-1] * @d[i-1]
        else
          @c[i] = 1 / @m[i]
          @d[i] = -1 * @n[i] * @ua + @fx.call(x) * @h**2
        end
      end
    end

    def getXForCurrentStep(i)
      @a + i * @h
    end
    alias X getXForCurrentStep

    def getQ(x)
      5 * (1 + Math.cos(x)**2)
    end
    alias Q getQ

    def getP(x)
      Math.cos(x)
    end
    alias P getP

    def getF(x)
      10 / (1 + 0.5 * x**2)
    end
    alias F getF
  end

  def self.getBiggestDifferenceBetweenArraysElements(arr1, arr2)
    max_diff = 0
    (0..arr2.size - 1).each do |i|
      curr_diff =(arr1[i * 2] - arr2[i])
      max_diff = curr_diff if curr_diff > max_diff
    end
    max_diff
  end

end
