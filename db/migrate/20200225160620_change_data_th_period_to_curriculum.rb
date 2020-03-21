class ChangeDataThPeriodToCurriculum < ActiveRecord::Migration[5.2]
  # 変更内容
  def up
    change_column :course_periods, :th_period, :string
  end

  # 変更前の状態
  def down
    change_column :course_periods, :th_period, :integer
  end
end
