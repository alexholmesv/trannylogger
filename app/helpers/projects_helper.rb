module ProjectsHelper

	def show_sent_icon(project)
		html=
			if project.sent
	    	"<div class='fa fa-check icon-center success'></div>"
			else
	    	"<div class='fa fa-times icon-center fail'></div>"
			end
		html.html_safe
	end


def show_paid_icon(paid)
		html=
			if paid
	    	"<div class='fa fa-check icon-center success'></div>"
			else
	    	"<div class='fa fa-times icon-center fail'></div>"
			end
		html.html_safe
	end

end
