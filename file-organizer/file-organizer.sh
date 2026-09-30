#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

usage() {
	echo -e " ${BLUE}------------------------------------------------${NC} "
	echo -e "${BLUE}|${NC} Usage ./organizer [options] existing_directory ${BLUE}|${NC}"
	echo -e "${BLUE}|${NC}                                                ${BLUE}|${NC}"
	echo -e "${BLUE}|${NC} Posible options:                               ${BLUE}|${NC}"
	echo -e "${BLUE}|${NC}  --dry-run                                     ${BLUE}|${NC}"
	echo -e "${BLUE}|${NC}                                                ${BLUE}|${NC}"
	echo -e " ${BLUE}------------------------------------------------ ${NC}"
}

main () {
	if [[ "$#" -lt 1 ]]; then
		usage
	elif [[ "$#" -gt 2 ]]; then
		usage
		exit 1
	else
		dry_run=false
		directory="$1"
		declare -A planned_dirs

		files_moved=0
		dirs_created=0

		if [[ "$#" -eq 2 ]]; then
			if [[ "$1" == "--dry-run" ]]; then
				dry_run=true
				directory="$2"		
			else
				usage
				exit 1
			fi
		fi
		
		directory=${directory%/}
		if [[ ! -d "$directory" ]]; then
			echo -e "${RED}Error:${NC} Directory '$directory' does not exist."
			usage
			exit 1
		fi
	
		while IFS= read -r file; do

			filename="${file##*/}"
			filetype=${filename##*.}
			
			if [[ "$filename" == .* || "$filename" == "$filetype" ]]; then
				filetype="no-extension"
			fi
				
			dir="$directory/$filetype"
			
			if [[ ! -d "$dir" ]]; then
				if [[ -z "${planned_dirs[$dir]+x}" ]]; then
    					planned_dirs["$dir"]=1

    					if [[ "$dry_run" == false ]]; then
        					mkdir -p "$dir"
						if [[ -d "$dir" ]]; then
							((dirs_created++))
    						fi
					else
	   					echo -e "${YELLOW}[DRY-RUN]${NC} Creating directory $dir"
						((dirs_created++))
    					fi
				fi
			fi
				
			if [[ $dry_run == false ]]; then
				mv "$file" "$dir"
				((files_moved++))
			else
				echo -e "${YELLOW}[DRY-RUN]${NC} \"$file\" -> \"$dir/$filename\""
				((files_moved++))
			fi

		done < <(find "$directory" -maxdepth 1 -type f)
		
		if [[ $dry_run == true ]]; then
			echo -e ""
			echo -e ""
		fi

		echo -e "${BLUE}==================================${NC}"
		echo -e "${BLUE}             SUMMARY${NC}              "
		echo -e "${BLUE}==================================${NC}"
		echo -e ""

		if [[ $dry_run == false ]]; then
			echo -e "${GREEN}Mode: NORMAL${GREEN}"
			echo -e ""
			echo -e "${GREEN}Files moved:${NC}         $files_moved"
			echo -e "${GREEN}Directories created:${NC} $dirs_created"
			echo -e ""
			echo -e "Result:"
			tree -a "$directory"
		else
			echo -e "${YELLOW}Mode: DRY-RUN${YELLOW}"
			echo -e ""
			echo -e "${GREEN}Files that will be moved:${NC}         $files_moved"
			echo -e "${GREEN}Directories that will be created:${NC} $dirs_created"
			
		fi
	
	fi
}

main "$@"
