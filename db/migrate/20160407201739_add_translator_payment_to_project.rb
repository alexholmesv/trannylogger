class AddTranslatorPaymentToProject < ActiveRecord::Migration
  def change
    add_column :projects, :translator_payment, :boolean
  end
end
