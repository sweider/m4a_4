module MainHelper

  class Equation1
    attr_accessor :c, :c1, :c2

    def initialize(c, ua, ub, a, b)
      @c = c
      @c1 = (4 * c * (ub - ua) - 5 * ( Math.sin(2 * b) - Math.sin(2 * a))) / (4 * (Math.sin(a) - Math.sin(b)))
      @c2 = ua - 1 / c * (5/4 * Math.sin(2 * a) + a - c1 * Math.sin(a))
    end

    def calculate(x)
      (1 / self.c) * (5 / 4 * Math.sin(2 * x) + x - self.c1 * Math.sin(x)) + self.c2
    end

    def calculate_in_range_with_step(range, step)
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

    def calculate_in_range_with_step(range, step)
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

    def get_values_in_range_with_step(range, step)
      result = []
      range.step(step).each { |currentX| result << @func.call(currentX) }
      result
    end
  end

  class DeltaFunction

    def initialize(x0, infinity_value)
      @x0 = x0
      @infinity_value = infinity_value
      @delta = ->(x){ (x - 0).abs < 0.00000001 ? @infinity_value : 0.0 }
    end
    def value(x)
      @delta.call(x - @x0)
    end
  end

  class PointHeatSupplier
    # @param x0 [Float] точка, в которую ставится источник тепла
    # @param [Float] power мощность источника тепла
    # @return [nil]
    def initialize(x0, power)
      @delta_func = DeltaFunction.new(x0, 100000)
      @power = power
      @x0 = x0
    end

    # @param [Float] x точка, для которой хотим получить значение функции
    # @return [Float] значение функции точечного источника тепла в заданной точке
    def value(x)
      @power * @delta_func.value(x)
    end

    # @param [Float] power новая мощность
    # @return [PointHeatSupplier] новый источник тепла в той же точке с новой мощностью
    def change_power(power)
      PointHeatSupplier.new(@x0, power)
    end
  end

  class FiniteDifferenceSolver
    def initialize(steps_count,a,ua,b,ub,alpha0, alpha1, beta0,beta1, qx, px, fx)
      @alpha0 = alpha0; @alpha1 = alpha1; @beta0 = beta0; @beta1 = beta1;
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
      @y[@steps_count] = (2 * @ub * @h - @beta1 * (@d[@steps_count] - @c[@steps_count - 1] * @d[@steps_count - 1])) /
                          (2 * @beta0 * @h + @beta1* (@c[@steps_count - 1] - (1 / @c[@steps_count])))
          #(@beta1 * @c[@steps_count - 2] * @d[@steps_count - 2] + @ub * @h) /
           #              (@beta1 * (1 + @c[@steps_count - 2]) + @beta0 * @h) #@ub
      (@steps_count - 1).downto(1).each { |i|
        @y[i] = @c[i] * (@d[i] - @y[i + 1])
      }
      @y[0] = (@ua * @h - @alpha1 * @y[1]) / (@alpha0 * @h - @alpha1)#(@alpha1 * @y[1] - @ua * @h) / (@alpha1 - @alpha0 * @h)#@ua
      {step: @h, y: @y}
    end

    protected
    def initialize_coefficients_arrays
      @h = (@b - @a).to_f / @steps_count
      @m = [@steps_count + 1]
      @n = [@steps_count + 1]
      @c = [@steps_count + 1]
      @d = [@steps_count + 1]
      @y = [@steps_count + 1]

      (0..(@steps_count)).each do |i|
        x = X(i)
        pi = @px.call(x)
        @m[i] = (2 * @qx.call(x) * @h**2 - 4) / (2 + @h * pi)
        @n[i] = (2 - @h * pi) / (2 + @h * pi)

        if i > 1
          @c[i] = 1 / (@m[i] - @n[i] * @c[i - 1])
          @d[i] = (2 * @fx.call(x) * @h**2) / (2 + @h * pi) - @n[i] * @c[i-1] * @d[i-1]
        else
          var = (@alpha1 - @alpha0 * @h)
          @c[i] = var / (@m[i] * var + @n[i] * @alpha1) #1 / @m[i]
          @d[i] = 2 * @fx.call(x) * @h**2 / (2 + pi * @h) + @n[i] * @ua * @h / var #@n[i] * @ub * @h / var + @fx.call(x) * @h**2 #-1 * @n[i] * @ua + @fx.call(x) * @h**2
        end
      end
    end

    def get_x_for_current_step(i)
      @a + i * @h
    end
    alias X get_x_for_current_step

    def get_q(x)
      5 * (1 + Math.cos(x)**2)
    end
    alias Q get_q

    def get_p(x)
      Math.cos(x)
    end
    alias P get_p

    def get_f(x)
      10 / (1 + 0.5 * x**2)
    end
    alias F get_f
  end

  class Lab1Task4Helper
    attr_reader :a

    def initialize
      @a = 0.5;  @b = 1.5; @ua = @ub = 1; @steps = 150
      @alpha1 = 0; @alpha0 = 1; @beta1 = 0; @beta0 = 1
    end

    def fill_array_with_charts_for_p3(array)
      fx = ->(x){ 5 * Math.sin(x) }

      #здесь и далее <name>_<a>_<b> -- нумерация соответствующая номеру в задании. kx3_1_a -- к из задания 1 пункт а
      k1_1_a = 1; k2_1_a = 10000
      kx_1_a = ->(x){ (x >= a && x <= (@b - @a).to_f / 2) ? k1_1_a : k2_1_a }
      kx_1_b = ->(x){ (x >= a && x <= (@b - @a).to_f / 2) ? k2_1_a : k1_1_a }

      solution_1_a = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx.call(x) /  kx_1_a.call(x) }
      ).solve
      solution_1_b = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx.call(x) /  kx_1_b.call(x) }
      ).solve

      k1_2_a = 1; k2_2_a = 5; k3_2_a = 10
      condition_step = (@b - @a).to_f / 3

      kx_2_a = ->(x){ x <= @a + condition_step ? k1_2_a : (x <= @a + 2 * condition_step ? k2_2_a : k3_2_a) }
      solution_2_a = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx.call(x) /  kx_2_a.call(x) }
      ).solve

      kx_2_b = ->(x){ x <= @a + condition_step ? k3_2_a : (x <= @a + 2 * condition_step ? k2_2_a : k1_2_a) }
      solution_2_b = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx.call(x) /  kx_2_b.call(x) }
      ).solve

      k = 3
      kx_2_c = ->(x){ x <= @a + condition_step || x > @a + 2 * condition_step ? k :  2 * k }
      solution_2_c = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx.call(x) /  kx_2_c.call(x) }
      ).solve

      kx_2_d = ->(x){ x <= a + condition_step || x > @a + 2 * condition_step ? 20 * k : k }
      solution_2_d = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx.call(x) /  kx_2_d.call(x) }
      ).solve

      array <<  { name: '3.1.a: k1 << k2', values: solution_1_a[:y], step: solution_1_a[:step] }
      array <<  { name: '3.1.b: k2 << k1', values: solution_1_b[:y], step: solution_1_b[:step] }
      array <<  { name: '3.2.a: k1<k2<k3', values: solution_2_a[:y], step: solution_2_a[:step] }
      array <<  { name: '3.2.b: k1>k2>k3', values: solution_2_b[:y], step: solution_2_b[:step] }
      array <<  { name: '3.2.c: k1=k,k2=2k,k3=k', values: solution_2_c[:y], step: solution_2_c[:step] }
      array <<  { name: '3.2.d: k1=20k,k2=k,k3=20k', values: solution_2_d[:y], step: solution_2_d[:step] }
    end

    # Заполняет массив хэшами графиков, для задания 10.4.4
    def fill_array_with_charts_for_p4(array)
      power = 1
      supplier_a = PointHeatSupplier.new(@a + (@b - @a) / 2, power)
      fx_a = ->(x) { supplier_a.value(x) }
      solution_a = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx_a.call(x)}
      ).solve

      supplier_b1 = PointHeatSupplier.new(@a + (@b - @a) / 3, power)
      supplier_b2 = PointHeatSupplier.new(@a + 2 * (@b - @a) / 3, power)
      fx_b = ->(x) {supplier_b1.value(x) + supplier_b2.value(x) }
      solution_b = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx_b.call(x) }
      ).solve

      supplier_c1 = supplier_b1.change_power(2 * power)
      fx_c = ->(x) { supplier_c1.value(x) + supplier_b2.value(x) }
      solution_c = MainHelper::FiniteDifferenceSolver.new(
          @steps, @a, @ua, @b, @ub, @alpha0, @alpha1, @beta0, @beta1,
          ->(*x){0}, ->(*x){0},
          ->(x) { fx_c.call(x) }
      ).solve

      array <<  { name: 'Один источник в центре', values: solution_a[:y], step: solution_a[:step] }
      array <<  { name: 'Два симметричных равномощных', values: solution_b[:y], step: solution_b[:step] }
      array <<  { name: 'Два симметричных разномощных', values: solution_c[:y], step: solution_c[:step] }
    end
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
