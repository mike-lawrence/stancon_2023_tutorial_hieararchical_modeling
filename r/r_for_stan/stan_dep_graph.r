#TODO:
# - inc_priors = c(T,F)
# - highlight parameters with no prior
# - highlight paramerers unconnected to data

file_to_stanc_to_code = function(
	file
	, includes_path = NULL
){
	file = fs::path_expand(file)
	args = c(file,'--print-canonical')
	if(!is.null(includes_path)){
		if(is.logical(includes_path)){
			(
				fs::path_dir(file)
				%>% fs::path('includes')
			) ->
				includes_path
		}else{
			includes_path = fs::path_expand(includes_path)
		}
		args = c(args,'--include-paths',includes_path)
	}
	out = processx::run(
		command = cmdstanr::cmdstan_path() %>% fs::path('bin','stanc')
		, args = args
		# , echo_cmd = T
	)
	if(is.null(out$stderr)){
		stop(out$stderr)
	}
	return(out$stdout)
}

stan_to_block_code_tbl = function(
		file # path to the stan file
		, includes_path = NULL # either path to includes, or T, in which case includes_path set to (file %>% fs::path_dir() %>% fs::path('includes'))
){

	(
		file_to_stanc_to_code(file,includes_path)
		#remove comments
		%>% str_remove_all(regex('\\/\\/.*'))
		#remove extra space
		%>% str_squish()
		####
		# squish replaced all whitespace, including newlines, with a space, so replace with newline
		####
		# replace space after ; with newline
		%>% str_replace_all('; ',fixed(';\n'))
		# replace space after } with newline
		%>% str_replace_all(fixed('} '),fixed('}\n'))
		# remove space before {
		%>% str_replace_all(fixed(' {'),fixed('{'))
		# ensure space after {
		%>% str_replace_all(fixed('{'),fixed('{ '))
		# ensure ONE space after {
		%>% str_replace_all(fixed('{  '),fixed('{ '))
		# add newline after {
		%>% str_replace_all(fixed('{ '),fixed('{\n'))
		# split by newlines
		%>% str_split_1(fixed('\n'))
		# add line number as name
		%>% magrittr::set_names(.,1:length(.))
	) ->
		clean_code_lines

	block_levels = c(
		'functions'
		, 'data'
		, 'transformed_data'
		, 'parameters'
		, 'transformed_parameters'
		, 'model'
		, 'generated_quantities'
	)
	(
		block_levels
		%>% str_replace('_',' ')
		%>% paste0(.,'\\{')
		%>% magrittr::set_names(.,block_levels)
		%>% map_dfr(
			.id = 'block'
			, .f = ~ (
				str_starts(
					string = clean_code_lines
					, pattern = .x
				)
				%>% which()
				%>% tibble(start=.)
			)
		)
		%>% arrange(start)
		%>% mutate(
			stop = c(start[2:n()]-1,length(clean_code_lines))
			, block = factor(block,levels=block_levels)
		)
		%>% mutate(
			code = list(clean_code_lines[(start+1):(stop-1)])
			, .by = block
		)
	)
}

extract_expression_lines_list = function(
		block_code_tbl
){
	(
		block_code_tbl$code
		%>% magrittr::set_names(.,block_code_tbl$block)
		%>% keep_at(
			at = c( # all except functions
				'data'
				, 'transformed_data'
				, 'parameters'
				, 'transformed_parameters'
				, 'model'
				, 'generated_quantities'
			)
		)
		%>% map(
			.f = ~(
				.x
				%>% .[str_detect(.,';')]
				%>% .[!str_detect(.,'return')]
				%>% str_remove(';')
				%>% str_squish()
				%>% str_trim()
			)
		)
	)
}

extract_declare_tbl = function(
	expression_lines_by_block_list
){
	extract_constraints <<- function(x,contraint){
		(
			x
			%>% str_extract(regex(paste0(contraint,'=\\d')))
			%>% str_remove(paste0(contraint,'='))
			%>% as.numeric()
		)
	}
	(
		expression_lines_by_block_list
		%>% map_dfr(
			.id = 'block'
			, .f = function(.x){
				(
					.x
					%>% .[!(str_detect(.,'~')|str_detect(.,'target'))]
					%>% .[
						str_starts(
							.
							, paste(
								c(
									NULL
									, 'array'
									, 'int'
									, 'real'
									, 'row_vector'
									, 'vector'
									, 'matrix'
									, 'simplex'
									, 'unit_vector'
									, 'ordered'
									, 'positive_ordered'
									, 'complex'
									, 'complex_vector'
									, 'complex_row_vector'
									, 'complex_matrix'
									, 'cov_matrix'
									, 'corr_matrix'
									, 'cholesky_factor_cov'
									, 'cholesky_factor_corr'
								)
								, collapse = '|'
							)
						)
					]
				) ->
					.x
				if(length(.x)==0){
					return(NULL)
				}
				x<<-.x
				(
					.x
					%>% str_remove_all('=[^>]+$')
					%>% str_trim()
					%>% str_remove_all(' ')
					%>% tibble(name=.)
					%>% mutate(
						order = 1:n()
						, array_dims_str = (
							name
							%>% str_extract('array\\[.+?\\]')
						)
						, name = case_when(
							!is.na(array_dims_str) ~ str_remove(name,fixed(array_dims_str))
							, T ~ name
						)
						, type_constraints_dims_str = (
							name
							%>% str_extract(
								paste(
									c(
										NULL
										, '^int(<.+?>)?'
										, '^real(<.+?>)?'
										, '^complex(<.+?>)?'
										, '^row_vector(<.+?>)?\\[.+?\\]'
										, '^vector(<.+?>)?\\[.+?\\]'
										, '^matrix(<.+?>)?\\[.+?\\]'
										, '^simplex(<.+?>)?\\[.+?\\]'
										, '^unit_vector(<.+?>)?\\[.+?\\]'
										, '^ordered(<.+?>)?\\[.+?\\]'
										, '^positive_ordered(<.+?>)?\\[.+?\\]'
										, '^complex_vector(<.+?>)?\\[.+?\\]'
										, '^complex_row_vector(<.+?>)?\\[.+?\\]'
										, '^complex_matrix(<.+?>)?\\[.+?\\]'
										, '^cov_matrix(<.+?>)?\\[.+?\\]'
										, '^corr_matrix(<.+?>)?\\[.+?\\]'
										, '^cholesky_factor_cov(<.+?>)?\\[.+?\\]'
										, '^cholesky_factor_corr(<.+?>)?\\[.+?\\]'
									)
									, collapse = '|'
								)
							)
						)
						, name = case_when(
							!is.na(type_constraints_dims_str) ~ str_remove(name,fixed(type_constraints_dims_str))
							, T ~ name
						)
						, lower = extract_constraints(
							type_constraints_dims_str
							, 'lower'
						)
						, upper = extract_constraints(
							type_constraints_dims_str
							, 'upper'
						)
						, offset = extract_constraints(
							type_constraints_dims_str
							, 'offset'
						)
						, multiplier = extract_constraints(
							type_constraints_dims_str
							, 'multiplier'
						)
						, type_dims_str = (
							type_constraints_dims_str
							%>% str_remove(regex('<.*>'))
						)
					)
					%>% separate_wider_delim(
						type_dims_str
						, delim = '['
						, too_few = 'align_start'
						, names = c('type','dims_str')
						, cols_remove = F
					)
					%>% mutate(
						dims_str = str_remove(dims_str,']')
					)
					%>% separate_wider_delim(
						dims_str
						, delim = ','
						, too_few = 'align_start'
						, names_sep = '_'
					)
					%>% mutate(
						array_dims_str2 = (
							array_dims_str
							%>% str_remove('array\\[')
							%>% str_remove('\\]')
						)
					)
					%>% separate_wider_delim(
						array_dims_str2
						, delim = ','
						, too_few = 'align_start'
						, names_sep = '_'
					)
					%>% rename_with(
						.fn = function(x){
							which_fix = (
								str_detect(x,'dims_str2_\\d')
								| str_detect(x,'dims_str_\\d')
							)
							(
								x[which_fix]
								%>% str_replace('dims_str2','dim')
								%>% str_replace('dims_str','dim')
							) ->
								x[which_fix]
							return(x)

						}
					)
					%>% select(name,starts_with('array_dim_'),type,starts_with('dim_'),lower:multiplier,everything())
					%>% arrange(desc(nchar(name)))
				)
			}
		)
	)
}

extract_target_tbl = function(
	expression_lines_by_block_list
){
	(
		expression_lines_by_block_list
		%>% pluck('model')
		%>% .[str_detect(.,'~')]#|str_detect(.,'target')] # TODO: handle target+=
		%>% tibble(line=.)
		%>% separate_wider_delim(
			line
			, delim = '~'
			, names = c('lhs','rhs')
		)
		%>% mutate(
			across(everything(),str_trim)
			, lhs = (
				lhs
				%>% str_remove(.,fixed('to_vector('))
				%>% str_remove(.,fixed(')'))
				%>% str_remove(.,'\\[.+?\\]$')
			)
			, rhs = (
				rhs
				%>% str_remove_all('\\[.+?\\]')
			)
		)
	)
}

extract_compute_tbl = function(
	expression_lines_by_block_list
){
	(
		expression_lines_by_block_list
		%>% keep_at(
			at = c(
				'transformed_data'
				, 'transformed_parameters'
				, 'model'
				, 'generated_quantities'
			)
		)
		%>% map_dfr(
			.id = 'block'
			, .f = ~ (
				.x
				%>% .[!(str_detect(.,'~')|str_detect(.,'target'))]
				%>% .[
					(
						str_detect(.,'lower') & str_detect(.,'upper') & (str_count(.,'=')==3)
					)
					| (
						(
							(
								str_detect(.,'lower') & (!str_detect(.,'upper'))
							)
							| (
								str_detect(.,'upper') & (!str_detect(.,'lower'))
							)
						)
						& (str_count(.,'=')==2)
					)
					| (
						(!str_detect(.,'lower')) & (!str_detect(.,'upper')) & (str_count(.,'=')==1)
					)
				]
				%>% str_remove_all('\\[.+?\\]')
				%>% str_replace_all( . , fixed('+=') , '=' )
				%>% str_replace_all( . , fixed('-=') , '=' )
				%>% tibble(
					line = .
				)
				%>% mutate(
					across(everything(),stringi::stri_reverse)
				)
				%>% separate_wider_delim(
					line
					, names = c('rhs','lhs')
					, delim = '='
					, too_many = 'merge'
				)
				%>% mutate(
					across(everything(),str_trim)
				)
				%>% separate_wider_delim(
					lhs
					, names = c('name')
					, delim = ' '
					, too_many = 'drop'
				)
				%>% bind_rows()
				%>% mutate(
					across(everything(),stringi::stri_reverse)
					, name = (
						name
						%>% str_remove_all(
							pattern = regex('\\[.+?\\]')
						)
					)
				)
				%>% select(name,rhs)
			)
		)
		%>% mutate(
			rhs = (
				rhs
				%>% str_remove_all('\\[.+?\\]')
			)
		)
	)
}

compute_dependency_tbl = function(
	declare_tbl
	, compute_tbl
	, target_tbl
){
	# get the declared variables sorted by length (used in extracting dependencies below)
	(
		declare_tbl
		%>% pull(name)
		%>% nchar()
		%>% order()
		%>% rev()
		%>% declare_tbl$name[.]
	) ->
		declared_names_sorted_by_nchar_desc

	dependencies = list()
	for(i_name in 1:nrow(target_tbl)){
		this_name = target_tbl$lhs[i_name]
		this_dependency = target_tbl$rhs[i_name]
		(
			this_dependency
			%>% str_extract('^.+?\\(')
			%>% str_remove('\\(')
		) ->
			this_dist
		this_dependency = str_remove(this_dependency,this_dist)
		this_dist = paste0(this_dist,'__',i_name)
		dependencies = c(
			dependencies
			, list(tibble(
				name = this_name
				, dependency = this_dist
			))
		)
		for(declared_name in declared_names_sorted_by_nchar_desc){
			if(str_detect(this_dependency,paste0('[^a-z_]',declared_name,'[^a-z_]'))){
				dependencies = c(
					dependencies
					, list(tibble(
						name = this_dist
						, dependency = str_trim(declared_name)
					))
				)
				this_dependency = str_remove_all(this_dependency,declared_name)
			}
		}
	}

	for(i_name in 1:nrow(compute_tbl)){
		this_name = compute_tbl$name[i_name]
		this_dependency = compute_tbl$rhs[i_name]
		for(declared_name in declared_names_sorted_by_nchar_desc){
			if(str_detect(paste('',this_dependency,''),paste0('[^a-z_]',declared_name,'[^a-z_]'))){
				declared_name = str_trim(declared_name)
				dependencies = c(
					dependencies
					, list(tibble(
						name = this_name
						, dependency = declared_name
					))
				)
				this_dependency = str_remove_all(this_dependency,declared_name)
			}
		}
	}
	bind_rows(dependencies)
}

env2list = function(
		omit = NULL
){
	ls_ = ls(envir = parent.frame())
	ls_ = ls_[ls_!=omit]
	eval.parent(
		parse(
			text= paste0(
				'list('
				, paste(ls_,ls_,sep='=',collapse=',')
				, ')'
			)
		)
	)
}

stan_dep_graph = function(
	file # path to the stan file
	, legend = c('left','right','none')
	, includes_path = NULL # either path to includes, or T, in which case includes_path set to (file %>% fs::path_dir() %>% fs::path('includes'))
	, font_size = NULL # either a single int or a min/max int
	, nodes_to_omit = NULL # to remove any unnecessary (usually data) nodes
	, label_split = NULL # string to use as newline delimiter for labels
){
	if(!is.null(legend)){
		legend = legend[1]
	}
	#getting code
	block_code_tbl = stan_to_block_code_tbl(file,includes_path)
	block_levels = levels(block_code_tbl$block)
	dag_block_levels = block_levels[block_levels!='functions']
	dag_block_labels = dag_block_levels %>% str_replace('_',fixed('\n'))

	# extracting expressions lines
	expression_lines_by_block_list = extract_expression_lines_list(block_code_tbl)

	#get declare_tbl
	(
		expression_lines_by_block_list
		%>% extract_declare_tbl()
		# for dag, label declares in model as TP, distributions as model
		%>% mutate(
			dag_block = case_when(
				block=='model' ~ 'transformed_parameters'
				, block=='distribution' ~ 'model'
				, T ~ block
			)
			, dag_block_fac = factor(
				dag_block
				, levels = dag_block_levels
				, labels = dag_block_labels
			)
			, dag_level = as.numeric(dag_block_fac)
		)
	) ->
		declare_tbl

	# extract the lines involving expressions that increment the target
	target_tbl = extract_target_tbl(expression_lines_by_block_list)

	# extract the lines involving computations
	compute_tbl = extract_compute_tbl(expression_lines_by_block_list)

	# compute dependencies_tbl
	dependency_tbl = compute_dependency_tbl(
		declare_tbl
		, compute_tbl
		, target_tbl
	)

	# compute nodes_df_plus
	(
		c(
			dependency_tbl$name
			, dependency_tbl$dependency
		)
		%>% unique()
		%>% .[str_detect(.,'__\\d*$')]
		%>% tibble(
			name = .
			, type = 'distribution'
			, dag_block_fac = factor('model',levels=dag_block_levels,labels=dag_block_labels)
			, dag_level = as.numeric(dag_block_fac)
			, dist_var = 0
		)
		%>% bind_rows(
			declare_tbl %>% mutate(dist_var=1)
		)
		%>% mutate(
			label = (
				name
				%>% str_remove(regex('__\\d*$'))
			)
		)
		%>% arrange(order,dag_level) #close
		%>% mutate(
			id = 1:n()
		)
		%>% filter(
			!(name %in% nodes_to_omit)
		)
	) ->
		node_df_plus

	# compute edge_df_plus
	(
		dependency_tbl
		%>% filter(
			!(dependency %in% nodes_to_omit)
		)
		%>% filter(
			!(name %in% nodes_to_omit)
		)
		%>% distinct()
		%>% rename(from_name = dependency,to_name = name)
		%>% left_join(
			node_df_plus %>% select(name,id,dag_block_fac) %>% rename(to_name=name,to=id,to_dag_block=dag_block_fac)
			, by = 'to_name'
		)
		%>% left_join(
			node_df_plus %>% select(name,id,dag_block_fac) %>% rename(from_name=name,from=id,from_dag_block=dag_block_fac)
			, by = 'from_name'
		)
		%>% mutate(
			id = 1:n()
			, color = case_when(
				(from_dag_block=='model') & (to_dag_block=='data') ~ 'red'
				, T ~ 'gray'
			)
			, dashes = case_when(
				(from_dag_block=='model') & (to_dag_block=='data') ~ T
				, T ~ F

			)
			, rel = NA
		)

	) ->
		edge_df_plus

	# reduce to just those nodes with edges
	(
		node_df_plus
		%>% filter(
			(name %in% edge_df_plus$to_name)
			|
			(name %in% edge_df_plus$from_name)
		)
		%>% select(id,dag_block,label,dag_block_fac,dag_level,order)
	) ->
		nodes_df

	# split node labels if requested
	if(!is.null(label_split)){
		(
			nodes_df
			%>% mutate(
				label = (
					label
					%>% str_replace(regex(paste0(label_split,'$')),fixed('$'))
					%>% str_replace(regex(paste0('^',label_split)),fixed('$'))
					%>% str_replace_all(label_split,fixed(paste0(label_split,'\n')))
					%>% str_replace_all(fixed('$'),label_split)
				)
			)
		) ->
			nodes_df
	}

	#computing legend nodes
	(
		tibble(
			dag_block_fac = factor(
				dag_block_levels
				, levels = dag_block_levels
				, labels = dag_block_labels
			)
			, dag_level = as.numeric(dag_block_fac)
		)
		%>% mutate(
			label = dag_block_fac
			, id = max(nodes_df$id) + 1:n()
		)
	) ->
		legend_nodes

	# computing font sizes (if requested)
	if(!is.null(font_size)){
		if(length(font_size)==1){
			nodes_df = mutate(nodes_df,fontsize=font_size)
			legend_nodes = mutate(legend_nodes,fontsize=font_size)
		}else{
			set_font_size = function(x){
				nchar = (
					x
					%>% str_split(fixed('\n'))
					%>% map_dbl(
						.f = ~ (
							.x
							%>% nchar()
							%>% max()
						)
					)
				)
				nchar_ratio = nchar / max(nchar)
				fontsize = 1 - nchar_ratio
				fontsize = fontsize - min(fontsize)
				fontsize = fontsize/max(fontsize)
				fontsize = fontsize*(font_size[2]-font_size[1]) + font_size[1]
				return(fontsize)
			}
			nodes_df = mutate(nodes_df,fontsize=set_font_size(label))
			legend_nodes = mutate(legend_nodes,fontsize=set_font_size(label))
		}
	}

	#make edges for legend
	(
		legend_nodes
		%>% filter(id!=max(id))
		%>% tibble(
			from = id
			, to = from+1
		)
		%>% select(from,to)
		%>% mutate(
			rel = NA
			, color = 'transparent'
		)
	) ->
		legend_edges

	#making some invisible nodes for better spacing of the legend
	(
		legend_nodes
		%>% mutate(
			id = max(id) + 1:n()
		)
	) ->
		legend_nodes2

	# ditto invisible edges
	(
		legend_edges
		%>% mutate(
			from = max(from)+1 + 1:n()
			, to = from+1
		)
	) ->
		legend_edges2

	# finally compose/render using DiagrammeR
	if(legend=='left'){
		(
			# order of nodes *does* affect layout
			bind_rows(
				legend_nodes %>% mutate(fontcolor='black') %>% mutate(node_order = 1)
				, nodes_df %>% mutate(fontcolor='black') %>% mutate(node_order = 3)
			)
			%>% mutate(
				color = (
					RColorBrewer::brewer.pal(6,'Set2')
					%>% rev()
					%>% .[dag_level]
				)
			)
			%>% bind_rows(
				legend_nodes2 %>% mutate(color='transparent',fontcolor=color) %>% mutate(node_order=2)
			)
			%>% arrange(node_order)
			%>% mutate(
				fillcolor = color
			)
		) ->
			nodes_to_render
		(
			#order of edges doesn't affect layout
			bind_rows(
				edge_df_plus %>% select(from,to,rel,color,dashes)
				, legend_edges
				, legend_edges2
			)
			%>% mutate(id=1:n())
		) ->
			edges_to_render
	}else{
		if(legend=='right'){
			(
				# order of nodes *does* affect layout
				bind_rows(
					nodes_df %>% mutate(fontcolor='black') %>% mutate(node_order = 1)
					, legend_nodes %>% mutate(fontcolor='black') %>% mutate(node_order = 3)
				)
				%>% mutate(
					color = (
						RColorBrewer::brewer.pal(6,'Set2')
						%>% rev()
						%>% .[dag_level]
					)
				)
				%>% bind_rows(
					legend_nodes2 %>% mutate(color='transparent',fontcolor=color) %>% mutate(node_order=2)
				)
				%>% arrange(node_order)
				%>% mutate(
					fillcolor = color
				)
			) ->
				nodes_to_render
			(
				#order of edges doesn't affect layout
				bind_rows(
					edge_df_plus %>% select(from,to,rel,color,dashes)
					, legend_edges
					, legend_edges2
				)
				%>% mutate(id=1:n())
			) ->
				edges_to_render

		}else{
			(
				# order of nodes *does* affect layout
				nodes_df
				%>% mutate(fontcolor='black')
				%>% mutate(node_order = 3)
				%>% mutate(
					color = (
						RColorBrewer::brewer.pal(6,'Set2')
						%>% rev()
						%>% .[dag_level]
					)
				)
				%>% arrange(node_order)
				%>% mutate(
					fillcolor = color
				)
			) ->
				nodes_to_render
			(
				#order of edges doesn't affect layout
				edge_df_plus
				%>% select(from,to,rel,color,dashes)
				%>% mutate(id=1:n())
			) ->
				edges_to_render
		}
	}
	(
		DiagrammeR::create_graph(
			nodes_df = nodes_to_render
			, edges_df = edges_to_render
		)
		%>% DiagrammeR::add_global_graph_attrs(
			"layout", "dot", "graph"
		)
		%>% DiagrammeR::add_global_graph_attrs( "rankdir", "UD", "graph")
		%>% DiagrammeR::render_graph()
	) ->
		out
	# adding all computed variables to out (which is a list but if printed prints the dag)
	# out$stan_dep_graph_vars = env2list(omit='out')
	return(out)
}

# # example_usage:
# library(tidyverse)
# out = stan_dep_graph(
# 	file = file
# 	, includes_path = T
# 	, font_size = c(6,9) # either a single value or min & max
# 	, nodes_to_omit = 'nI'
# 	, label_split = '_'
# )


# library(tidyverse)
# (
# 	# '~/_/axem/code/location_aggregation/stan/bold_as_slopes.stan'
# 	# '~/_/code/gp_play_2023/stan/gp.stan'
# 	'~/_/research/CAST_Sam/_Analysis/stan/hwg.stan'
# 	# '~/_/code/repos/benchmark_stan_models/models/hbg/stan/hbg_c.stan'
# 	# '~/_/code/repos/benchmark_stan_models/models/hbg/stan/hbg_nc.stan'
# 	# '~/_/code/repos/benchmark_stan_models/models/hmg/stan/hmg.stan'
# ) ->
# 	file
# #file.edit(file)
# out = stan_dep_graph(
# 	file = file
# 	, includes_path = T
# 	, font_size = c(6,9) # either a single value or min & max
# 	, nodes_to_omit = 'nI'
# 	, label_split = '_'
# )
# print(out)
# View(out$stan_dep_graph_vars$nodes_df)
# View(out$stan_dep_graph_vars$edge_df_plus)
# View(out$stan_dep_graph_vars$compute_tbl)
# View(out$stan_dep_graph_vars$target_tbl)
# View(out$stan_dep_graph_vars$declare_tbl)


#commented code below associated with attempts to use visNetwork:
#require(visNetwork)
# %>% render_graph(
# 	output='visNetwork'
# )
# # %>% visLayout(
# # 	randomSeed = 1
# # 	# , clusterThreshold = 50
# # )
# %>% visHierarchicalLayout(
# 	sortMethod = 'directed'
# 	# sortMethod = 'hubsize'
# 	, parentCentralization = F
# 	, shakeTowards = 'leaves'
# 	# , shakeTowards = 'roots'
# )
# # %>% visPhysics(enabled=F)
# %>% visNodes(font=list(vadjust=-40)) # fragile?
# # %>% visEdges()
# %>% visLegend(n_basis_fns
# 	addNodes = (
# 		nodes_df
# 		%>% select(dag_block_fac,color,dag_level)
# 		%>% distinct()
# 		%>% mutate(label=as.character(dag_block_fac))
# 		%>% arrange(dag_level)
# 	)
# )
