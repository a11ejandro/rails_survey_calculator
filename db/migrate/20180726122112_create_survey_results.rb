class CreateSurveyResults < ActiveRecord::Migration[5.1]
  def change
    create_table :survey_results do |t|
      t.float :value
      t.references :task, foreign_key: true
    end
  end
end
