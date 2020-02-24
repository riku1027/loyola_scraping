class CreateEvaluationCriteria < ActiveRecord::Migration[5.2]
  def change
    create_table :evaluation_criteria do |t|
      t.float :evaluation_attendance
      t.float :evaluation_report, null: false
      t.float :evaluation_class_participation
      t.float :evaluation_final_exam
      t.float :evaluation_midterm_exam
      t.float :evaluation_regular_exam
      t.float :evaluation_reaction_paper
      t.float :evaluation_short_test
      t.float :evaluation_others
      t.references :curriculum, foreign_key: true

      t.timestamps
    end
  end
end
