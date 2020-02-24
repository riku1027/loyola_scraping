class AddCoulumnToCurriculum < ActiveRecord::Migration[5.2]
  def change
    add_column    :curriculums, :faculty, :string
    add_column    :curriculums, :department, :string
    add_column    :curriculums, :start_year, :string
    add_column    :curriculums, :level, :integer
    add_column    :curriculums, :main_teacher_name, :string
    add_column    :curriculums, :credits, :integer
    add_column    :curriculums, :keywords, :string
  end
end

