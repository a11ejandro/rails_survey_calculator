class RubyCalculatorNoAr
  include Sidekiq::Worker

  def perform(task_id)
    # Task processing time start
    time = Time.now

    rows = get_page_for_task(task_id)
    return if rows.count.zero?

    total_avg = page_avg(rows)

    create_survey_result(task_id, total_avg)

    # Task processing duration
    duration = Time.now - time

    Statistic.create(task_id: task_id, handler_type: 'ruby no AR',
                     duration: duration, collection_size: rows.count)
  end

  def page_avg(rows)
    min = max = sum = 0
    rows.each do |value|
      max = value if value > max
      min = value if value < min
      sum += value
    end

    avg = sum / rows.count
    (min + max + avg) / 3
  end

  def get_page_for_task(task_id)
    task_sql = <<-SQL
      SELECT tasks.page, tasks.per_page FROM tasks WHERE tasks.id = #{task_id} LIMIT 1
    SQL

    task_row = ActiveRecord::Base.connection.select_one(task_sql)

    page = task_row['page']
    per_page = task_row['per_page']

    offset = per_page * ((page = page.to_i - 1) < 0 ? 0 : page)

    page_sql = <<-SQL
      SELECT survey_results.value FROM survey_results LIMIT #{per_page} OFFSET #{offset}
    SQL

    ActiveRecord::Base.connection.select_values(page_sql)
  end

  def create_survey_result(task_id, value)
    survey_result_sql = <<-SQL
      INSERT INTO survey_results (task_id, value) VALUES (#{task_id}, #{value})
    SQL

    ActiveRecord::Base.connection.insert(survey_result_sql)
  end
end
