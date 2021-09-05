#!/bin/bash

# Copy mp3 files from one folder to anoter with flat and rename
# Usage:
# ./mmove.sh <source> <dest> [<format>] [--dry-run]
# <source> - source folder for looking *.mp3 files recursively
# <dest> - destination folder
# <format> - format for filename
# --dry-run - do not copy files

SRC_FOLDER=$1
DEST_FOLDER=$2
FORMAT=$3
DRY_RUN=

if [ "$4" == "--dry-run" ]; then
    DRY_RUN=1
fi

if [ "${FORMAT}" == "--dry-run" ]; then
    DRY_RUN=1
    FORMAT=
fi

if [ -z "${FORMAT}" ]; then
    FORMAT='$TPE - $TIT2'
fi

function get_vars {
    read -ra vars <<< $(sed 's/[^$]*\($[[:alnum:]]*\)[^$]*/\1 /g' <<< ${FORMAT})
    unique=$(printf "%s\n" "${vars[@]}" | sort -u)
    echo "${unique[@]}"
}

function get_id3_tag {
    tags="$1"
    tag="$2"
    echo "${tags}" | grep "${tag}" | head -1 | sed "s/[^:]*: \(.*\)/\1/g"
}

function format_name {
    file="$1"
    tags=$(id3info "${file}")
    format="$2"
    result="${format}"

    vars=$(get_vars "${format}")
    while IFS= read -r var; do
        result=$(sed "s/${var}/$(get_id3_tag "${tags}" "${var:1}")/g" <<< "${result}")
    done <<< "$vars"
    echo "${result}"
}

function copy_file {
    file="$1"
    dest="$2"
    format="$3"
    name=$(format_name "${file}" "${format}")
    file_name=$(basename -- "$file")
    ext=".${file_name##*.}"
    dest="${dest%%/}/${name}${ext}"
    echo $1 "=>" ${dest}
    cp "${file}" "${dest}"
}

find ${SRC_FOLDER} -name "*.mp3" | sort | while read file_name; do copy_file "$file_name" "${DEST_FOLDER}" "${FORMAT}" ${DRY_RUN}; done
