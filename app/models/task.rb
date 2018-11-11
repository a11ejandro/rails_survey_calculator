class Task < ApplicationRecord
  after_commit :process_in_background, on: :create

  has_many :statistics

  private

  def process_in_background
    RubyCalculator.perform_async(id)
    RubyCalculatorNoAr.perform_async(id)
    Sidekiq::Client.push('class' => 'GoSurveyCalculator',
                         'args' => [id],
                         'queue' => 'go_survey_calculator')
  end
end
