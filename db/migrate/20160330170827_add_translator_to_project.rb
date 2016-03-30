class AddTranslatorToProject < ActiveRecord::Migration
  def change
  	add_column :projects, :translator_id, :integer
    add_index :projects, :translator_id
  end
end
