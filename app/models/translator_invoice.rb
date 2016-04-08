class TranslatorInvoice < ActiveRecord::Base
  belongs_to :project
  belongs_to :translator
end
