#!/bin/bash

script_path=$(dirname $0)
dir_path=$1
type="CM" #CM|TP|TD
add_tex=TRUE

today_date=$(LC_TIME=fr_FR.UTF-8 date '+%d %B %Y')
today_date_digit_format=$(LC_TIME=fr_FR.UTF-8 date '+%Y-%m-%d')

base_tex_format_filename=base_tex_format.tex
subject=$(basename $dir_path)

last_item=$(ls $dir_path -1 | grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}-$type-[0-9]+" | sort -V | tail -n 1)
if [[ -z "$last_item" ]]; then
    number=0
else
    number=$(echo "$last_item" | grep -o '[0-9]*$')
fi

new_number=$((number + 1))

new_item="${today_date_digit_format}-${type}-${new_number}"

mkdir ${dir_path}/${new_item}

save_path="${dir_path}/${new_item}/${new_item}.tex"
title="$(echo "$subject" | tr '_' ' ' | sed -e 's/\b\(.\)/\u\1/g') | ${type^^}: $new_number"

if [ add_tex ]; then
    cp ${script_path}/${base_tex_format_filename} $save_path

    sed -i "s#\\\renewcommand\*{\\\today}{DATE_PLACEHOLDER}#\\\renewcommand\*{\\\today}{$today_date}#" $save_path
    sed -i "s#\\\title{TITLE_PLACEHOLDER}#\\\title{$title}#" $save_path
fi
