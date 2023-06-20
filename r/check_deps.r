check_deps = function(deps,action=c('install','stop','warn')){
	if(length(action)){
		action = action[1]
	}else{
		stop('"action" must have a value of either "install", "stop", or "warn"')
	}
	to_install = c()
	for(dependency in deps){
		if (0==length(find.package(dependency, quiet = TRUE))) {
			to_install = c(to_install,dependency)
			if(action!='install'){
				if(action=='stop'){
					f = stop
				}else{
					f = warning
				}
				f('Please install the "',dependency,'" package using `install.packages("',dependency,'")`')
			}
		}
	}
	if(action!='install'){
		return(length(to_install)==0)
	}else{
		if(length(to_install)>0){
			cat('Installing the following packages:\n\t- ',paste(to_install,collapse='\n\t- '))
			install.packages(to_install)
		}
	}
}
