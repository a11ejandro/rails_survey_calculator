desc 'Populate survey results'

namespace :db do
  desc 'Generates 100000 survey results'
  task populate_survey_results: :environment do
    records = []
    100_000.times do |time|
      value = rand(1000)
      sr = { value: value }

      records << sr

      next unless (time % 5000).zero?

      puts "Builded #{time} entries"
      puts 'Saving...'
      SurveyResult.create records
      records = []
    end
  end
end
