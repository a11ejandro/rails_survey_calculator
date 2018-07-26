class RubyCalculator
  include Sidekiq::Worker

  def perform(task_id)
    # Task processing time start
    time = Time.now

    task = Task.find(task_id)

    db_page = SurveyResult.page(task.page, task.per_page)
    return if db_page.count.zero?

    total_avg = page_avg(db_page)

    SurveyResult.create(task_id: task_id, value: total_avg)

    # Task processing duration
    duration = Time.now - time

    Statistic.create(task_id: task_id, handler_type: 'ruby', duration: duration,
                     collection_size: db_page.count)
  end

  def page_avg(db_page)
    min = max = sum = 0
    db_page.find_in_batches do |batch|
      batch.each do |survey_result|
        max = survey_result.value if survey_result.value > max
        min = survey_result.value if survey_result.value < min
        sum += survey_result.value
      end
    end

    avg = sum / db_page.count

    (min + max + avg) / 3
  end
end
