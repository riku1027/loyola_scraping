class CreateCoursePeriods < ActiveRecord::Migration[5.2]
  def change
    create_table :course_periods do |t|
      t.string  :period_code
      t.string  :day_of_week
      t.integer :th_period

      t.timestamps
    end
  end
end
