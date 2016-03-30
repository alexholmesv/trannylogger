class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :email
      t.text :address
      t.string :rut

      t.timestamps null: false
    end
  end
end
