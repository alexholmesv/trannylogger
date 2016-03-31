$(document).ready(function() {
    $("#project_words").keyup(function(){
   calculate_total();
		});
		$("#project_rate").keyup(function(){
   calculate_total();
		});
		$("#project_extras").keyup(function(){
   calculate_total();
		});
});

function calculate_total(){
	words = $("#project_words").val()?$("#project_words").val():1
	rate = $("#project_rate").val()?$("#project_rate").val():1
	extras = parseInt($("#project_extras").val()?$("#project_extras").val():0);
	result = parseInt(words*rate)
	result += extras
	$("#calc_total").html("$"+result);
};

