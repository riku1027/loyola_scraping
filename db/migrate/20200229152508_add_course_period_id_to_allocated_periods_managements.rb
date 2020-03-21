class AddCoursePeriodIdToAllocatedPeriodsManagements < ActiveRecord::Migration[5.2]
  def change
    add_column :allocated_periods_managements, :course_period_id, :integer
  end
end
