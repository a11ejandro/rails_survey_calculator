class SurveyResult < ApplicationRecord
  scope :page, ->(page, per_page) { limit(per_page).offset(per_page * ((page = page.to_i - 1) < 0 ? 0 : page)) }
end
