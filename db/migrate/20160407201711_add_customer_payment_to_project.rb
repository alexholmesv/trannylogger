class AddCustomerPaymentToProject < ActiveRecord::Migration
  def change
    add_column :projects, :customer_payment, :boolean
  end
end
