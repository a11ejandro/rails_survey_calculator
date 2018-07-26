class Task < ApplicationRecord
  after_create :process_in_background

  private
  def process_in_background
    RubyCalculator.perform_async(id)
  end
end
