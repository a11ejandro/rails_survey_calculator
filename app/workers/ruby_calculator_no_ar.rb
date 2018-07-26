class RubyCalculatorNoAr
  include Sidekiq::Worker

  def perform(task_id)
    # Task processing time start
    time = Time.now

    task = Task.find(task_id)

    rows = get_page(task.page, task.per_page)
    return if rows.count.zero?

    total_avg = page_avg(rows)

    SurveyResult.create(task_id: task_id, value: total_avg)

    # Task processing duration
    duration = Time.now - time

    Statistic.create(task_id: task_id, handler_type: 'ruby no AR',
                     duration: duration, collection_size: rows.count)
  end

  def page_avg(rows)
    min = max = sum = 0
    rows.each do |row|
      value = row['value']
      max = value if value > max
      min = value if value < min
      sum += value
    end

    avg = sum / rows.count
    (min + max + avg) / 3
  end

  def get_page(page, per_page)
    offset = per_page * ((page = page.to_i - 1) < 0 ? 0 : page)

    sql = <<-SQL
      SELECT survey_results.value FROM survey_results LIMIT #{per_page} OFFSET #{offset}
    SQL

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end
end
