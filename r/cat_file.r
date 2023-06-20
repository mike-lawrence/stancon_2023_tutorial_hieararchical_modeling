cat_file = function(file){
	(
		file
		%>% read_file()
		%>% cat()
	)
	return(invisible(NULL))
}
