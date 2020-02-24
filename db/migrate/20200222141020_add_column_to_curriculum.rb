class AddColumnToCurriculum < ActiveRecord::Migration[5.2]
  def change
    add_column :curriculums, :participants_num, :integer
    add_column :curriculums, :grade_a,          :float
    add_column :curriculums, :grade_b,          :float
    add_column :curriculums, :grade_c,          :float
    add_column :curriculums, :grade_d,          :float
    add_column :curriculums, :grade_e,          :float
    add_column :curriculums, :grade_other,      :float
    add_column :curriculums, :average_grade,    :float
  end
end
