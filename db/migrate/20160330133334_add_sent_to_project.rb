class AddSentToProject < ActiveRecord::Migration
  def change
    add_column :projects, :sent, :boolean
  end
end
