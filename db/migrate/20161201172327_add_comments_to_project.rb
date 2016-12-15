class AddCommentsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :comments, :text
  end
end
