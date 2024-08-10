#!/bin/bash

########################################################## INITIALIZATION

input="$1"

path_to_info="ENTER YOUR PATH"
info_file="${path_to_info}/recent-info.txt"

# check info-file
if [[ ! -f "$info_file" ]]; then
        echo "info-file \"${info_file}\" doesnt exists!" >&2
        return
elif [[ ! -s "$info_file" && "$input" != -n && "$input" != -cs ]]; then
        echo -e "info-file \"${info_file}\" is empty!\nplease add new path" >&2
        if [[ "$input" != -i && "$input" != -if ]]; then
            return 
        fi
fi

########################################################## FUNCTIONS
open_path(){
# getting line in file
    if [[ ${1:0:1} == - ]]; then
        echo "incorrect input!" >&2
        return
    fi
    last="$(wc -l < ${info_file})"
    if [[ "$1" == n || ! -s "$info_file" ]]; then
        line="$last"
    elif [[ -z "$1" || "$1" == w ]];then
        line=1
    elif [[ "$1" =~ ^[0-9]+$ ]]; then
        if [[ "$1" -gt 0 && "$1" -le "$last" ]]; then
            line="$1"
        else
            echo "incorrect index!" >&2
            return
        fi
    else
# searching matching key -> to get line
        match=$(echo "$1" | tr -cd '0-9a-zA-Z ')
        line=$(awk 'BEGIN {FS=";"}( $3 ~ /\<'"$match"'\>/){print NR;exit}' "$info_file")
        if [[ -z "$line" ]]; then
            echo "match not found!" >&2
            return
        fi                
    fi
# getting path from file
    path=$(awk 'BEGIN {FS=";"}'"NR==${line}"'{print $1}' "$info_file")
    if [[ ! -d "$path" ]]; then
        echo "incorrect path!" >&2
        return
    fi
# opening
    echo "opening: $path"
    if [[ "$1" == w || "$2" == w ]]; then
        gnome-terminal --working-directory="$path"
    else
        cd "$path" || return
    fi
}

add_path_key(){
# setting new key    
    if [[ -z "$1" ]]; then
        echo "key" 
    else
        new_key=$(echo "$1" | tr -cd '0-9a-zA-Z ')
        if [[ -z "$new_key" ]]; then
            echo "new key must contain letters or digits!" >&2
            echo "key" 
        else
            echo "$new_key"
        fi
    fi
}

add_path(){
# checking passed arguments -> initial values
    if [[ -d "$1" ]]; then
        path="$1"
        line="$2"
        new_key="$3"
    else
        echo "setting pwd, because path doesnt exists"
        path="$(pwd)"   
        line="$1"
        new_key="$2"
    fi
# creating file line content
    save="$path"
    save+=";"
    save+="$(date +%F_%T)"
    save+=";"
# getting line in file, seting file line content
    if [[ "$line" == n || ! -s "$info_file" ]]; then
        save+=$(add_path_key "$new_key")   
        echo "$save" >> "$info_file"
        echo "saved at the bottom: $path"
    elif [[ -z "$line" ]];then
        save+=$(add_path_key "$new_key")   
        sed -i "1 i ${save}" "$info_file"
        echo "saved at the top: $path"
    elif [[ "$line" =~ ^[0-9]+$ ]]; then
        if [[ "$line" -gt 0 && "$line" -le "$(wc -l < ${info_file})" ]]; then
            save+=$(add_path_key "$new_key")   
            sed -i "${line} i ${save}" "$info_file"
            echo "saved at the ${line} line: $path"
        else
            echo "incorrect index!" >&2
            return
        fi
    else
# searching matching key -> to get line, seting file line content 
        temp="$line"
        match=$(echo "$line" | tr -cd '0-9a-zA-Z ')
        line=$(awk 'BEGIN {FS=";"}( $3 ~ /\<'"$match"'\>/){print NR;exit}' "$info_file")
        if [[ -z "$line" ]]; then
            echo "match not found!, setting as key" >&2
            save+=$(add_path_key "$temp")   
            sed -i "1 i ${save}" "$info_file"
            echo "saved at the top: $path"
        else
            save+=$(add_path_key "$new_key")   
            sed -i "${line} i ${save}" "$info_file"
            echo "saved at the ${line} line: $path"
        fi                
    fi
    echo 
    print_paths "$info_file"
}

delete_path(){
# getting line in file
    last="$(wc -l < ${info_file})"
    if [[ "$1" == n || ! -s "$info_file" ]]; then
        line="$last"
    elif [[ -z "$1" ]];then
        line=1
    elif [[ "$1" =~ ^[0-9]+$ ]]; then
        if [[ "$1" -gt 0 && "$1" -le "$last" ]]; then
            line="$1"
        else
            echo "incorrect index!" >&2
            return
        fi
    else
# key matching
        match=$(echo "$1" | tr -cd '0-9a-zA-Z ')
        line=$(awk 'BEGIN {FS=";"}( $3 ~ /\<'"$match"'\>/){print NR;exit}' "$info_file")
        if [[ -z "$line" ]]; then
            echo "match not found!" >&2
            return
        fi
    fi
# asking
		echo -e "Are you sure to delete path ??? (yes ENTER ,no any key)" >&2 
        awk 'BEGIN {FS=";"}(NR=='"${line}"'){print NR " -> " $1 " -> " $2 " -> ( " $3 " )"}' "$info_file"
# reading key with asci code
		read -r -sn1 key
		asci="$(printf "%d\n" "'$key")"
		if [[ "$asci" == 0 ]]; then 
# deleing    
            sed -i "${line}d" "$info_file"
            echo "deleted"
            echo 
            print_paths "$info_file"          
        fi      
}

clear_paths(){
# asking
        echo -e "Are you sure to clear all saved paths ??? (yes ENTER ,no any key)" >&2 
#reading key with asci code
		read -r -sn1 key
		asci="$(printf "%d\n" "'$key")"
		if [[ "$asci" == 0 ]]; then 
            echo -n "" > "$info_file"   
            echo "cleared"
        fi                
}

swap_paths(){
# getting lines to swap in file
    if [[ "$1" =~ ^[0-9]+$ && "$2" =~ ^[0-9]+$ ]]; then
        if [[ "$1" -gt 0 && "$1" -le "$(wc -l < ${info_file})" && "$2" -gt 0 && "$2" -le "$(wc -l < ${info_file})" ]]; then
            line1="$1"
            line2="$2"
        else
            echo "incorrect index!" >&2
            return
        fi
    else
# keys matching
        match1=$(echo "$1" | tr -cd '0-9a-zA-Z ')
        match2=$(echo "$2" | tr -cd '0-9a-zA-Z ')
        line1=$(awk 'BEGIN {FS=";"}( $3 ~ /\<'"$match1"'\>/){print NR;exit}' "$info_file")
        line2=$(awk 'BEGIN {FS=";"}( $3 ~ /\<'"$match2"'\>/){print NR;exit}' "$info_file")
        if [[ -z "$line1" || -z "$line2" ]]; then
            echo "match not found!" >&2
            return
        fi
    fi
# paths swapping    
    temp1="$(sed -n ${line1}p ${info_file})"
    temp2="$(sed -n ${line2}p ${info_file})"
    sed -i "${line1} c ${temp2}" "$info_file"
    sed -i "${line2} c ${temp1}" "$info_file"
    echo "swapped:"
    awk 'BEGIN {FS=";"}(NR=='"${line1}"'){print NR " -> " $1 " -> " $2 " -> ( " $3 " )"}' "$info_file"
    awk 'BEGIN {FS=";"}(NR=='"${line2}"'){print NR " -> " $1 " -> " $2 " -> ( " $3 " )"}' "$info_file"
    echo 
    print_paths "$info_file"
}

update_paths(){
# getting line in file    
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        if [[ "$1" -gt 0 && "$1" -le "$(wc -l < ${info_file})" ]]; then
            line="$1"
        else
            echo "incorrect index!" >&2
            return
        fi
    else
# key matching    
        match=$(echo "$1" | tr -cd '0-9a-zA-Z ')
        line=$(awk 'BEGIN {FS=";"}( $3 ~ /\<'"$match"'\>/){print NR;exit}' "$info_file")
        if [[ -z "$line" ]]; then
            echo "match not found!" >&2
            return
        fi
    fi
# conditional updating    
    if [[ "$2" == "t" ]]; then 
        save="$(date +%F_%T)"
        temp=$(awk 'BEGIN {FS=";"}(NR=='"${line}"'){print $1 ";" "'"$save"'" ";" $3}' "$info_file")
    elif [[ -d "$2" ]]; then
        save="$2"
        temp=$(awk 'BEGIN {FS=";"}(NR=='"${line}"'){print "'"$save"'" ";" $2 ";" $3}' "$info_file")
    else
        echo "incorrect path! updating pwd" >&2
        save="$(pwd)"
        temp=$(awk 'BEGIN {FS=";"}(NR=='"${line}"'){print "'"$save"'" ";" $2 ";" $3}' "$info_file")
    fi
    sed -i "${line} c ${temp}" "$info_file"
# print        
    echo "updated:"
    awk 'BEGIN {FS=";"}(NR=='"${line}"'){print NR " -> " $1 " -> " $2 " -> ( " $3 " )"}' "$info_file"
    echo 
    print_paths "$info_file"
}

update_key(){
# getting line in file    
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        if [[ "$1" -gt 0 && "$1" -le "$(wc -l < ${info_file})" ]]; then
            line="$1"
        else
            echo "incorrect index!" >&2
            return
        fi
    else
# key matching        
        match=$(echo "$1" | tr -cd '0-9a-zA-Z ')
        line=$(awk 'BEGIN {FS=";"}( $3 ~ /\<'"$match"'\>/){print NR;exit}' "$info_file")
        if [[ -z "$line" ]]; then
            echo "match not found!" >&2
            return
        fi
    fi
# key update    
    new_key=$(add_path_key "$2")
    temp=$(awk 'BEGIN {FS=";"}(NR=='"${line}"'){print $1 ";" $2 ";" "'"$new_key"'"}' "$info_file")
    sed -i "${line} c ${temp}" "$info_file"
    echo "key have been set: ${new_key}"
    awk 'BEGIN {FS=";"}(NR=='"${line}"'){print NR " -> " $1 " -> " $2 " -> ( " $3 " )"}' "$info_file"
    echo 
    print_paths "$info_file"
}

copy_info_file(){
    if [[ -z "$1" ]]; then
        echo "please set copy name!" >&2
        return
    fi
    cp "$info_file" "${path_to_info}/${1}"
    echo "copy created"
}

set_info_file(){
# file name check    
    if [[ -z "$1" ]]; then
        echo "please set copy name!" >&2
        return
    fi
    if [[ ! -f "${path_to_info}/${1}" ]]; then
        echo "file \"${1}\" doesnt exists!" >&2
        return
    fi
# asking
		echo -e "Are you sure to replace your all paths by file \"${1}\" ??? (yes ENTER ,no any key)" >&2 
# reading key with asci code
		read -r -sn1 key
		asci="$(printf "%d\n" "'$key")"
		if [[ "$asci" == 0 ]]; then 
# copping        
            cp "${path_to_info}/${1}" "$info_file"
            echo "copy set:"
            echo
            print_paths "$info_file"         
        fi    
}

show_paths(){
# file name check        
    if [[ -z "$1" ]]; then
        to_show="$info_file"
    elif [[ -f "${path_to_info}/${1}" ]]; then
        to_show="${path_to_info}/${1}"
    else
        echo "file \"${1}\" doesnt exists!" >&2
        return
    fi
# print    
    print_paths "$to_show"
}

show_files(){
    if [[ -z "$1" ]]; then
        ls "$path_to_info"
    else
        ls "$1" "$path_to_info"
    fi
}

print_paths(){
    awk 'BEGIN {FS=";"}{print NR " -> " $1 " -> " $2 " -> ( " $3 " )"}' "$1"
}

delete_file(){
# file name check    
    if [[ -f "${path_to_info}/${1}" ]]; then
        if [[ "${path_to_info}/${1}" == "$info_file" ]]; then
            echo "you trying to delete info file!" >&2
            return
        fi
    else
        echo "file \"${1}\" doesnt exists!" >&2
        return
    fi
# ask nad delete 
    rm -i "${path_to_info}/${1}"
}

########################################################## MAIN SWITCH
case "$input" in
# show info
-i)
    show_paths "$2";;
# new path -> save paths
-n) 
    add_path "$2" "$3" "$4";;
# delete path
-d) 
    delete_path "$2";;
# clear
-cl) 
    clear_paths;;
# swap
-s) 
    swap_paths "$2" "$3";;
# set key        
-k)
    update_key "$2" "$3";;
# update
-u)
    update_paths "$2" "$3";;    
# find text
-ft)
    show_paths "$3" | grep "$2";;
# show files
-if)
    show_files "$2";;
# keep -> create coppy
-c) 
    copy_info_file "$2";;
# set coppy
-cs) 
    set_info_file "$2";;
# delete file
-df) 
    delete_file "$2";;
# sort from last to first
-t)
    sort -t";" -r -k2 "$info_file" -o "$info_file"
    print_paths "$info_file";;
# sort from first to last 
-tr)
    sort -t";" -k2 "$info_file" -o "$info_file"
    print_paths "$info_file";;
# sort alphabetically
-a)
    sort -t";" -k1 "$info_file" -o "$info_file"
    print_paths "$info_file";;
# sort reversed alphabetically
-ar)
    sort -t";" -r -k1 "$info_file" -o "$info_file"
    print_paths "$info_file";;
# sort by key
-ak)
    sort -t";" -k3 "$info_file" -o "$info_file"
    print_paths "$info_file";;
# sort by key reversed 
-akr)
    sort -t";" -r -k3 "$info_file" -o "$info_file"
    print_paths "$info_file";;
# open path
*)
    open_path "$input" "$2";;
esac    