class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :translator
  belongs_to :user
	before_save :set_total
	has_many :translator_invoices
	accepts_nested_attributes_for :translator_invoices

	def set_total
		if self.total.blank?
			self.words ||= 0
			self.rate ||= 0
			self.extras ||= 0
			self.total = (self.words * self.rate) + self.extras
		end

		
	end

end
