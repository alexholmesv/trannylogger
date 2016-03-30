class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.belongs_to :client, index: true, foreign_key: true
      t.string :name
      t.date :date_received
      t.integer :words
      t.float :rate
      t.float :extras
      t.float :total

      t.timestamps null: false
    end
  end
end
