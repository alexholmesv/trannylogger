class AddProjectIdToTranslator < ActiveRecord::Migration
  def change
    add_column :translators, :project_id, :integer
  end
end
