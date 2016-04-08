class CreateTranslatorInvoices < ActiveRecord::Migration
  def change
    create_table :translator_invoices do |t|
      t.belongs_to :project, index: true, foreign_key: true
      t.belongs_to :translator, index: true, foreign_key: true
      t.integer :invoice_number
      t.date :date
      t.boolean :project_sent
      t.boolean :invoice_sent

      t.timestamps null: false
    end
  end
end
