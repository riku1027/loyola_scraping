class AddSemesterToCurriculums < ActiveRecord::Migration[5.2]
  def change
    add_column :curriculums, :semester, :string
  end
end
