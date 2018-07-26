class CreateStatistics < ActiveRecord::Migration[5.1]
  def change
    create_table :statistics do |t|
      t.references :task, foreign_key: true
      t.string :handler_type
      t.integer :collection_size
      t.float :duration
    end
  end
end
