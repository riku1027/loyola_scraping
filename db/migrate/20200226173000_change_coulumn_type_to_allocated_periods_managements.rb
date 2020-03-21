class ChangeCoulumnTypeToAllocatedPeriodsManagements < ActiveRecord::Migration[5.2]
  def up
    change_column :allocated_periods_managements, :curriculum_id,     :integer
    change_column :allocated_periods_managements, :course_periods_id, :integer
  end

  def down
    change_column :allocated_periods_managements, :curriculum,     references
    change_column :allocated_periods_managements, :course_periods, references
  end
end
