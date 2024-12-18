#!/usr/bin/env bash

FILE_SIZE_LIMIT_MB=${FILE_SIZE_LIMIT_MB:-500}
REMOVE_PARTS_AFTER=${REMOVE_PARTS_AFTER:-true}
REMOVE_PARTS_REDUCED_AFTER=${REMOVE_PARTS_REDUCED_AFTER:-true}
CURR_PATH=$(dirname "$(realpath "$0")")

function show_help(){
    printf "\nUSAGE: %s <file> <error|warning|debug|info|trace>\n" "$(basename "$0")"
    printf "\nOPTIONS (env variables):\n\n"
    printf "  FILE_SIZE_LIMIT_MB          Threshold file size in Mb. Larger files will be split in parts for processing\n"
    printf "                              Default: 500\n\n"
    printf "  REMOVE_PARTS_AFTER          Part files will be removed after processing\n"
    printf "                              Default: true\n\n"
    printf "  REMOVE_PARTS_REDUCED_AFTER  Reduced part files will be removed after processing\n"
    printf "                              Default: true\n\n"
}

if [[ $1 == "--help" ]]; then
  show_help
  exit 0
fi
if [[ $# -ne 2 ]]; then
  show_help
  exit 0
fi


LNAV_LOG_LEVEL=$2
file_to_process=$1
file_size_Mb=$(du -m  "$file_to_process"| cut -f1)
file_dir=$(dirname $file_to_process)
file_name=$(basename $file_to_process)
parts_dir="_${file_name}_parts"


function split_error_log_file(){
  number_of_parts=$1
  pushd $file_dir > /dev/null
  mkdir -p $parts_dir
  echo -e "\n... splitting $file_name into smaller $number_of_parts parts"
  split -cd -a 3 -n $number_of_parts $file_name $parts_dir/${file_name}.part_
  reconcile_split_parts
  popd > /dev/null
}

function reconcile_split_parts(){
  echo -e "\n... reconciling $number_of_parts parts files (split may occur in the middle of a log msg):\n"
  part_files=("$parts_dir"/*)
  for ((idx = 0; idx < number_of_parts - 1; idx++)); do
      echo -e "\treconciling ${part_files[idx]}"
      while IFS= read -r line || [ -n "$line" ]; do
          if [[ $line =~ ^\[([0-9]{4}) ]]; then
              break
          fi
          echo "$line" >> "${part_files[idx]}"
          sed -i '' '1d' "${part_files[idx + 1]}"
      done < "${part_files[idx + 1]}"
  done
}

function reduce_log(){
  OUTPUT_FOLDER=$1
  FILE_OR_PART=$2
  export LNAV_OUTPUT_FOLDER=$OUTPUT_FOLDER
  export LNAV_LOG_LEVEL=$LNAV_LOG_LEVEL
  lnav -q \
      -n ${FILE_OR_PART} \
      -f $CURR_PATH/reduce_to_level.lnav
  if [[ ! -e "${FILE_OR_PART}.reduced" ]]; then
    touch "${FILE_OR_PART}.reduced"
  fi
}

function reduce_log_parts(){
  pushd $file_dir > /dev/null
  part_files=("$parts_dir"/*)
  count=${#part_files[@]}
  count=$((count - 1))
  echo -e "\n... reducing $number_of_parts parts to level $LNAV_LOG_LEVEL only"
  for idx in "${!part_files[@]}"; do
      printf  "\treducing log part $idx of $count"
      START_TIME=$(date +%s)
      reduce_log $parts_dir $file_dir/${part_files[idx]}
      END_TIME=$(date +%s)
      ELAPSED_TIME=$((END_TIME - START_TIME))
      REMAINING=$(( ((count - idx) * ELAPSED_TIME) / 60 ))
      if [[ $REMOVE_PARTS_AFTER == true ]]; then
        rm ${part_files[idx]}
      fi
      printf " (~ $REMAINING minutes left)\n"
  done
  popd > /dev/null
}

function join_and_moved_reduced(){
  pushd $file_dir > /dev/null
  echo -e "\n... joining all reduced parts"
  while IFS= read -r file; do
      if [[ -s $file ]]; then
          cat "$file" >> "$file_dir/$file_name.reduced"
      fi
  done < <(find "$parts_dir" -type f -name "*reduced" | while IFS= read -r file; do
    printf "%s %s\n" "$(stat -f "%m" "$file" 2>/dev/null || stat --format="%Y" "$file")" "$file"
  done | sort -n | cut -d' ' -f2-)
  if [[ $REMOVE_PARTS_REDUCED_AFTER == true ]]; then
    rm $file_dir/$parts_dir/*.reduced
  fi
  rmdir "$parts_dir" 2>/dev/null
  popd > /dev/null
}

echo "file_to_process: $file_to_process"
echo "file_dir: $file_dir"
echo "file_name: $file_name"
echo "file_size_Mb: $file_size_Mb"
if [[ $file_size_Mb -gt $FILE_SIZE_LIMIT_MB ]]; then
  number_of_parts=$(( (file_size_Mb / FILE_SIZE_LIMIT_MB) + 1))
  split_error_log_file  $number_of_parts
  reduce_log_parts
  join_and_moved_reduced
else
  reduce_log $file_dir $file_to_process
fi

