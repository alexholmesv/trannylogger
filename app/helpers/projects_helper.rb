module ProjectsHelper

	def show_sent_icon(project)
		html=
			if project.sent
	    	"<div class='fa fa-check fa-2x icon-center success'></div>"
			else
	    	"<div class='fa fa-times fa-2x icon-center fail'></div>"
			end
		html.html_safe
	end


end
