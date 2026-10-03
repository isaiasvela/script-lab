#!/bin/bash

# Author: Isaías Vela

set -euo pipefail

# Normal
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bright
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m';
BMAGENTA='\033[1;35m';
BCYAN='\033[1;36m';
BWHITE='\033[1;37m'

# Types
BOLD='\033[1m';
DIM='\033[2m';
UNDERLINE='\033[4m'
NC='\033[0m'


trap ctrl_c INT
trap errorControl ERR

function errorControl {
	echo -e "${RED}[-] Error:${NC} in line $LINENO" >&2
	exit 1
}

function ctrl_c {
	echo -e "${YELLOW}[!]${NC} Canceled by user"
	exit 130
}


function usage() {
	echo "Usage: $0 [-n] [-h] directory" >&2
}

function helpPanel() {
	echo -e "\n${BLUE}=== ${NC}${BBLUE}${BOLD}HELP PANEL${NC}${BLUE} ===${NC}"
	echo -e "\n${BCYAN}${BOLD}[*]${NC} Usage: $0 ${CYAN}[-n] [-h]${NC} ${BLUE}directory${NC}"
	echo -e "\t${CYAN}-n${NC} dry-run option"
	echo -e "\t${CYAN}-h${NC} help panel\n"
}

function ensure_tree() {
  	command -v tree >/dev/null && return 0

  	echo -e "\n${BYELLOW}${BOLD}[!]${NC} WARNING: ${CYAN}tree${NC} is not installed. It is used to show the result"
  	read -r -p "${BCYAN}${BOLD}[?]${NC} Install now? [y/N] " ans </dev/tty
  	case "$ans" in
    		y|Y)
			echo -e "${BCYAN}${BOLD}[*]${NC} Installing tree"
			if command -v apt >/dev/null; then sudo apt install -y tree
      			elif command -v dnf >/dev/null; then sudo dnf install -y tree
      			elif command -v pacman >/dev/null; then sudo pacman -S --noconfirm tree
      			else echo "${BCYAN}${BOLD}[*]${NC} Please install it manually" >&2; exit 1
      			fi
      		;;
    		*) echo -e "${BRED}${BOLD}[+]${NC} Exit..." ;;
  esac
}

function main () {

	dry_run=false
	declare -A planned_dirs

	declare -i files_moved=0
	declare -i dirs_created=0
	
	while getopts ":nh" arg; do
		case $arg in
			n) dry_run=true ;;
			h) helpPanel; exit 0 ;;
			\?) echo -e "\n${BRED}${BOLD}[-]${NC} ${BOLD}Invalid Option:${NC} ${CYAN}-$OPTARG${NC}\n" >&2; usage; exit 2 ;;
		esac
	done

	shift $((OPTIND-1))
	
	if [[ $# -ne 1 ]]; then
		usage
		exit 2
	fi

	directory=$1
	directory=${directory%/}


	ensure_tree

	if [[ ! -d "$directory" ]]; then
		echo -e "${BRED}${BOLD}[-]${NC} Invalid Directory: ${BLUE}$directory${NC}" >&2; usage; exit 1;
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
						((++dirs_created))
    					fi
				else
					echo -e "${BYELLOW}${BOLD}[!]${NC} ${DIM}[DRY-RUN]${NC} Creating directory${NC} ${BLUE}$dir${NC}"
					((++dirs_created))
    				fi
			fi
		fi
				
		if [[ "$dry_run" == false ]]; then
			mv "$file" "$dir"
			((++files_moved))
		else
			echo -e "${BYELLOW}${BOLD}[!]${NC} ${DIM}[DRY-RUN]${NC} Moving ${BLUE}$file${NC} -> ${BLUE}$dir/$filename${NC}"
			((++files_moved))
		fi

	done < <(find "$directory" -maxdepth 1 -type f)
		
	echo -e "\n\n${DIM}${BLUE}=== ${NC}${BBLUE}${BOLD}SUMMARY${NC}${DIM}${BLUE} ===${NC}\n"

	if [[ "$dry_run" == false ]]; then
		echo -e "${GREEN}Mode: NORMAL${NC}\n"
		echo -e "${BGREEN}${BOLD}[+]${NC} Files moved:${NC} $files_moved"
		echo -e "${BGREEN}${BOLD}[+]${NC} Directories created:${NC} $dirs_created\n"
		echo -e "Result:"
		tree -a "$dir"
		echo ""
	else
		echo -e "${YELLOW}Mode: DRY-RUN${NC}\n"
		echo -e "${BYELLOW}${BOLD}[!]${NC} Files that will be moved: ${MAGENTA}$files_moved${NC}"
		echo -e "${BYELLOW}${BOLD}[!]${NC} Directories that will be created: ${MAGENTA}$dirs_created${NC}\n"
			
	fi		
}

main "$@"
