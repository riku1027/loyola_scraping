class ChangeColumnToCurriculum < ActiveRecord::Migration[5.2]
  # 変更内容
  def up
    change_column :curriculums, :registration_code, :string, null: false, unique: true
  end

  # 変更前の状態
  def down
    change_column :curriculums, :registration_code, :string, null: true
  end
end
