class BasicTables < ActiveRecord::Migration[7.1]
  def change
    
    create_table :users do |t|
      t.integer :telegram_id
      t.string :first_name
      t.string :role
      t.integer :group_id
      t.timestamps
    end

    create_table :groups do |t|
      t.string :group_name
      t.timestamps
    end

    create_table :subjects do |t|
      t.string :subject_name
      t.timestamps
    end

    create_table :teachers do |t|
      t.string :teacher_name
      t.timestamps
    end

    create_table :timetables do |t|
      t.references :subject, null: false, foreign_key: true, index: true
      t.references :group, null: false, foreign_key: true, index: true
      t.references :teacher, null: false, foreign_key: true, index: true
      t.integer :day_of_week
      t.integer :lesson_order
      t.timestamps
    end
  end
end
