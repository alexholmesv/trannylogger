class AddTranslatorInvoiceToProject < ActiveRecord::Migration
  def change
    add_column :projects, :translator_invoice, :integer
  end
end
