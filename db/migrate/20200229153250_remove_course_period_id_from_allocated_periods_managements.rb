class RemoveCoursePeriodIdFromAllocatedPeriodsManagements < ActiveRecord::Migration[5.2]
  def change
    remove_column :allocated_periods_managements, :course_periods_id, :string
  end
end
