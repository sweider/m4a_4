
class MainController < ApplicationController
  def index

  end

  def calculate_task_1
    step = 0.01
    start = 0.5
    endd = 1.5
    @chart_params = {}
    @chart_params[:start] = 0.5
    @chart_params[:end] = endd
    @chart_params[:step] = step
    @chart_params[:charts] = []

    set_1 = MainHelper::Equation1.new(1, 1, 1, 0.5, 1.5)
    @chart_params[:charts] << { values: set_1.calculate_in_range_with_step(start..endd, step), name: 'Set 1' }

    set_2 = MainHelper::Equation1.new(2, 1, 1, 0.5, 1.5)
    @chart_params[:charts] << { values: set_2.calculate_in_range_with_step(start..endd, step), name: 'Set 2' }

    set_3 = MainHelper::Equation1.new(0.1, 1, 1, 0.5, 1.5)
    @chart_params[:charts] << { values: set_3.calculate_in_range_with_step(start..endd, step), name: 'Set 3' }

    set_4 = MainHelper::Equation2.new(1, 1, 1, 0.5, 1)
    @chart_params[:charts] << { values: set_4.calculate_in_range_with_step(start..endd, step), name: 'Set 4' }

    set_5 = MainHelper::Equation1.new(1, -1, 1, 0.5, 1.5)
    @chart_params[:charts] << { values: set_5.calculate_in_range_with_step(start..endd, step), name: 'Set 5' }

    set_6 = MainHelper::Equation1.new(1, 1, -1, 0.5, 1.5)
    @chart_params[:charts] << { values: set_6.calculate_in_range_with_step(start..endd, step), name: 'Set 6' }

    set_7 = MainHelper::Equation1.new(1, -1, -1, 0.5, 1.5)
    @chart_params[:charts] << { values: set_7.calculate_in_range_with_step(start..endd, step), name: 'Set 7' }
  end

  def calculate_task_2
    @exampleChart = { start: 0, end: 1, charts: []}
    example_exact = MainHelper::Function.new(->(x) { Math.exp(-x) * ((2 * Math.exp(1) - 1) * x + 1) })
    example_solver = MainHelper::FiniteDifferenceSolver.new( 10, 0, 1, 1, 2, 1, 0 , 1, 0, ->(*x){ 1 }, ->(*x){ 2 }, ->(*x) { 0 } )
    @exampleChart[:charts] << { values: example_exact.get_values_in_range_with_step(@exampleChart[:start]..@exampleChart[:end], 0.05), name: 'Exact', step: 0.05 }
    self.fill_array_with_charts(@exampleChart[:charts], example_solver, 0.01)

    @task_charts = []
    @chart_params = { start: 0, end: 1.5, step: 0.1}
    task_precision = 0.05
    task_solver = MainHelper::FiniteDifferenceSolver.new(
        10, 0, 5, 1.5, 0, 1, 0 , 1, 0, #step counts, a, ua, b, ub, alpha0, alpha1, beta0 ,beta 1
        ->(x) { 8 / (11 + 0.25 * x**2) }, #5 * (1 + Math.cos(x)**2) }, #Q(x)
        ->(x) { -0.5 + Math.sin(x) }, #Math.cos(x) }, #P(x)
        ->(x) { 5 * (1 - x**2) }#10 / (1 + 0.5 * x**2) } #F(x)
    )
    self.fill_array_with_charts(@task_charts, task_solver, task_precision)
  end

  def calculate_task_4
    task_4_helper = MainHelper::Lab1Task4Helper.new
    @chart_params = { start: task_4_helper.a, title_p3:'10.4.3', title_p4: ' 10.4.4', charts_p3: [], charts_p4: []}
    task_4_helper.fill_array_with_charts_for_p3(@chart_params[:charts_p3])
    task_4_helper.fill_array_with_charts_for_p4(@chart_params[:charts_p4])
  end

  def calculate_task_5
    c = 0.925; a = 0; b = 1.7
    kx = ->(x) { x <= c ? 1.2 : 0.5 }
    qx = ->(x) { x <= c ? 7.5 : 12 }
    fx = ->(x) { 7 * Math.exp(-x) }
    px = ->(*x) { 0 }
    task_solver = MainHelper::FiniteDifferenceSolver.new(10, a, 0, b, 0, 0.5, -1 * kx.call(a), 0.5, kx.call(b), qx, px, fx)
    @chart_params = { charts:[], start: a }
    self.fill_array_with_charts(@chart_params[:charts], task_solver, 0.001)
  end

  protected
  def fill_array_with_charts(array, task_solver, task_precision)
    iteration = 0; previous_result = {}; precision = nil
    loop do
      result = task_solver.solve
      precision = MainHelper::getBiggestDifferenceBetweenArraysElements(result[:y], previous_result[:y]) unless previous_result.empty?
      previous_result = result
      array << { values: result[:y], step: result[:step], name: "With step:#{result[:step]}" }
      iteration += 1
      break if ( !precision.nil? && precision < task_precision || iteration > 50)
      task_solver.double_steps_count!
    end
  end
end
