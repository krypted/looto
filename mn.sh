#!/bin/bash

# Global variables
#########################################################################
# Grep flags
# Delimeter by space for each flag
# By default
# Display color on standard output and line number
# when using grep via function run_grep
# For more, please check https://linuxcommand.org/lc3_man_pages/grep1.html
GLOBAL_GREP_FLAGS=("--color=auto" "-n")
#########################################################################

#########################################################################
### Helper functions 
#########################################################################

function is_mach-o_file {
    FILE_PATH=$1
    if file -b "$FILE_PATH" | grep -q "Mach\-O"  ; then
        return 0
    fi
    return 1
}

function contain_search_param {
    _symbols=$1
    search_param=$2
    if echo "$_symbols" | grep -q "$search_param" ; then
        return 0
    fi
    return 1
}

function run_grep {
	search_param=$1
	flags=$2
	_symbols=$3

	args=("$search_param")

	if [ -n "$flags" ]; then args+=("$flags"); fi
	for gb_grep_flag in "${GLOBAL_GREP_FLAGS[@]}"
	do
		args+=("$gb_grep_flag")
	done

	echo "$_symbols" | grep "${args[@]}"
}

function recurse_dir {
	bin=$1;
	search_param=$2;
	grep_flag=$3;
	cur_path=$(pwd);
	# uncomment line below to see what path is being searched
	#echo "Searching $cur_path:";
	for f in *;
	do
		if [[ -f "${f}" ]]; then
			IFS=$'\n';
			_current_file="$cur_path/${f}"
			if is_mach-o_file "$_current_file" ; then
				_symbols="$(nm "$_current_file")"
				if contain_search_param "$_symbols" "$search_param" ; then
					printf "File: %s\n" "$_current_file"
					run_grep "$search_param" "$grep_flag" "$_symbols"
				fi
			fi

		fi
	done
	for d in *;
	do
		if [[ -d "${d}" ]]; then
			cd "${d}";
			if [ $? -eq 0 ]; then
				recurse_dir "$bin" "$search_param" "$grep_flag"
				cd ..
			fi
		fi
	done
}

function display_help {
	echo "usage: [options: -r] [path] [search_param] [grep_flags]";
	echo "    -r    recursively search through all directories";
	echo "Please provide full path as argument to path";
	echo "Usage Example"
	echo "To search case insentitive, append grep flag -i"
	echo " bash looto.sh $(pwd) str -i"
	echo "To search resurively with case insentivie"
	echo " bash looto.sh -r /usr/bin str -i"
}

#########################################################################
### Main program
#########################################################################

RUN_RECURSIVE=false

while getopts "r" flag;
do
    case "${flag}" in
        r) 
			RUN_RECURSIVE=true
			;;	
		*) 
			display_help
			;;
    esac
done

orig_IFS=IFS;

if [ $# -eq 0 ] ; then
	display_help;
elif [ $# -lt 2 ] || [ $# -gt 4 ] ; then
	printf "Must have [path] [search_param] as positional parameters!\n"
	display_help
elif [ "$RUN_RECURSIVE" = false ] && [ $# -lt 4 ]; then
	IFS=':'; bin_path=$1; appended_path=$"$PATH:/usr/lib";
	search_param=$2;
	grep_flag=$3;
	for path in $appended_path
	do
		(contents=$(ls $path);
		IFS=$'\n';
		for bin in $contents
		do
		_current_file="$path/$bin"
		if is_mach-o_file "$_current_file" ; then
			_symbols="$(nm "$_current_file")"
			
			if contain_search_param "$_symbols" "$search_param" ; then
				printf "File: %s\n" "$_current_file"
				run_grep "$search_param" "$grep_flag" "$_symbols"
			fi
		fi
		done)
	done
elif [ "$RUN_RECURSIVE" = true ] && [ $# -lt 5 ] ; then
	cd "/";
	recurse_dir "$2" "$3" "$4";
else
	printf "Invalid arguments or paramaeters"
	display_help
fi

IFS=$orig_IFS
