class CreateCurriculums < ActiveRecord::Migration[5.2]
  def change
    create_table :curriculums do |t|
      t.string :name
      t.string :registration_code, null: false
      t.string :start_time
      t.string :period
      t.string :teacher

      t.timestamps
    end
  end
end
