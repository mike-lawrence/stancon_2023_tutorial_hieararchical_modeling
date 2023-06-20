add_indices = function(x){
	(
		x
		%>% select(name)
		%>% distinct()
		%>% filter(str_detect(name,fixed('[')))
		%>% separate_wider_delim(
			cols = name
			, delim = fixed('[')
			, names = c('name_no_index','index')
			, cols_remove = F
		)
		%>% mutate(index=str_remove(index,']'))
		%>% separate_wider_delim(
			cols = index
			, delim = fixed(',')
			, names_sep = '_'
			, too_few = 'align_start'
		)
		%>% mutate(
			across( -starts_with('name'), as.integer )
		)
		%>% left_join(
			x
			, y = .
			, by = 'name'
		)
		%>% mutate(
			name_no_index = case_when(
				is.na(name_no_index) ~ name
				, T ~ name_no_index
			)
		)
	)
}
