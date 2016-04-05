class Translator < ActiveRecord::Base
	has_many :projects

	def last_project_name
		last_project ? last_project.name : nil
	end

	def last_project
		projects.last
	end

end
