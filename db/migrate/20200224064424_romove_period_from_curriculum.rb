class RomovePeriodFromCurriculum < ActiveRecord::Migration[5.2]
  def change
    remove_column :curriculums, :period, :integer
  end
end
