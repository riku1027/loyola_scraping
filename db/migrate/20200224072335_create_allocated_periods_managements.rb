class CreateAllocatedPeriodsManagements < ActiveRecord::Migration[5.2]
  def change
    create_table :allocated_periods_managements do |t|
      t.references  :curriculum,     foreign_key: true
      t.references  :course_periods, foreign_key: true

      t.timestamps
    end
  end
end
