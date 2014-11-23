
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

  def test
    @exampleChart = { start: 0, end: 1, charts: []}
    example_exact = MainHelper::Function.new(->(x) { Math.exp(-x) * ((2 * Math.exp(1) - 1) * x + 1) })
    example_solver = MainHelper::FiniteDifferenceSolver.new( 10, 0, 1, 1, 2, 1, 0 , 1, 0, ->(*x){ 1 }, ->(*x){ 2 }, ->(*x) { 0 } )
    @exampleChart[:charts] << { values: example_exact.get_values_in_range_with_step(@exampleChart[:start]..@exampleChart[:end], 0.05), name: 'Exact', step: 0.05 }
    self.fill_array_with_charts(@exampleChart[:charts], example_solver, 0.01)
  end

  def calculate_task_6
    a = 0.5; ua = 1; b = 1.5; ub = 1; l = b - a; step_x = 0.01; step_t = 0.05; max_t = 210 * step_t;
    kx = ->(x){ 1 / Math.cos(x) }; dkx_dx = ->(x){ 2 * Math.sin(x) / (Math.cos(2 * x) + 1) }
    f_u_x_t = ->(u,x,t){ 5 * Math.sin(x) * (1 - Math.exp(-t)) };
    phi_x = ->(x) { (ub - ua) * (x - a) / l + ua }
    alpha_x_t = ->(x,t){ kx.call(x) }; beta_x_t = ->(x,t){ dkx_dx.call(x)}
    phi1 = ->(t) {1}; phi2 = ->(t){1.5}
    solver = MainHelper::ExplicitDifferenceSchemaSolver.new(a,b,phi1,phi2,step_x,max_t,step_t, alpha_x_t, beta_x_t, phi_x,f_u_x_t, true).calculate!
    @chart_params = { explicit_charts: [], start: a }
    @chart_params[:explicit_charts] << solver.get_nearest_function_values_for_time(step_t,'t')
    @chart_params[:explicit_charts] << solver.get_nearest_function_values_for_time(step_t * 20,'20t')
    @chart_params[:explicit_charts] << solver.get_nearest_function_values_for_time(step_t * 200, '200t')
  end

  def calculate_lab_2
    a = 0; b = 1; step_x = (b - a).to_f / 10; k = 0.4; t_max = 0.1; t_min = 0; step_t = (t_max - t_min) / 80
    phi_x = ->(x){x}; g1_t = ->(t){0}; g2_t = ->(t){1}; f_x_t = ->(x,t){1};
    solver = MainHelper::ImplicitDifferenceSchemaSolver.new(a,b,step_x,t_min,t_max, step_t,k, phi_x, g1_t,g2_t,f_x_t, false).calculate!
    @chart_params = { impl_charts: [],expl_charts:[], start: a }

    alpha_x_t = ->(x,t) {k}; beta_x_t = ->(x,t){0}; f_u_x_t = ->(u,x,t){ f_x_t.call(x,t) }
    expl_solver = MainHelper::ExplicitDifferenceSchemaSolver.new(a,b, g1_t,g2_t,step_x,t_max,step_t,alpha_x_t,beta_x_t, phi_x,f_u_x_t, false).calculate!

    (0..80).step(16).each { |i|
      @chart_params[:impl_charts] << solver.get_nearest_function_values_for_time(i,"#{i}t_i")
      @chart_params[:impl_charts] << expl_solver.get_nearest_function_values_for_time(i, "#{i}t_e")
    }
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