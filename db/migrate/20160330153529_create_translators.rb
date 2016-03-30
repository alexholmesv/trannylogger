class CreateTranslators < ActiveRecord::Migration
  def change
    create_table :translators do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
