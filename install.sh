#!/usr/bin/env bash

CURR_FOLDER="$(dirname "$0")"
pushd $CURR_FOLDER > /dev/null
SOURCE_FOLDER="$(pwd)/resources"
DESTINATION_FOLDER="$HOME/.lnav/formats/installed"
VERSION="default"

function show_help(){
    echo -e "\nSYNOPSIS\n\tinstall.sh [--help] [--remove]\n"
    echo -e "\nDESCRIPTION\n\tThe following options are available:"
    echo -e "\n\t--help      show this help"
    echo -e "\t--remove    (uninstall) remove resources  linked to the ~/.lnav/format_files/installed  folder\n"
}

function set_version(){
  GERRIT_VERSIONS=(`ls $SOURCE_FOLDER`)
  INDEX=1
  echo -e "\nYou are about to install default format_files and scripts, valid for most Gerrit versions."
  echo -e "Specific format_files for the following Gerrit versions are supported: \n"
  for i in "${GERRIT_VERSIONS[@]}"; do
    echo -e "\t${INDEX})\t$i"
    let INDEX=${INDEX}+1
  done
  echo ""
  read -p "Do you want to support a specific Gerrit version ?  (1 - ${#GERRIT_VERSIONS[@]} , enter to accept defaults)" veridx
  VERSION="${GERRIT_VERSIONS[$veridx -1]}"
}

function uninstall {
  for file in "$DESTINATION_FOLDER"/*.json; do
      if [ -L "$DESTINATION_FOLDER/$(basename $file)" ]; then
        rm "$DESTINATION_FOLDER/$(basename $file)"
      fi
  done
  echo -e "\n\tRemoved Gerrit format_files from lnav"
  for file in "$DESTINATION_FOLDER"/*.lnav; do
      if [ -L "$DESTINATION_FOLDER/$(basename $file)" ]; then
        rm "$DESTINATION_FOLDER/$(basename $file)"
      fi
  done
  echo -e "\tRemoved Gerrit scripts from lnav\n"
}

function install_format_files() {
  for file in "$SOURCE_FOLDER/default"/formats/*.json; do
    format_file=$(basename $file)
    if [ -e "$SOURCE_FOLDER/$VERSION/formats/$format_file" ]; then
      echo -e "\tAdding format_file for Gerrit $VERSION to lnav: $format_file"
      ln -s "$SOURCE_FOLDER/$VERSION/formats/$format_file" "$DESTINATION_FOLDER/"
    else
      echo -e "\tAdding format_file to lnav: $format_file"
      ln -s "$SOURCE_FOLDER/default/formats/$format_file" "$DESTINATION_FOLDER/"
    fi
  done
}

function install_script_files() {
  for file in "$SOURCE_FOLDER/default"/scripts/*.lnav; do
    script_file=$(basename $file)
    if [ -e "$SOURCE_FOLDER/$VERSION/scripts/$script_file" ]; then
      echo -e "\tAdding script for Gerrit $VERSION to lnav: $script_file"
      ln -s "$SOURCE_FOLDER/$VERSION/scripts/$script_file" "$DESTINATION_FOLDER/"
    else
      echo -e "\tAdding script to lnav: $script_file"
      ln -s "$SOURCE_FOLDER/default/scripts/$script_file" "$DESTINATION_FOLDER/"
    fi
  done
}

function install(){
  mkdir -p "$DESTINATION_FOLDER"
  set_version
  uninstall
  install_format_files
  install_script_files
}

case $1 in
    --remove)
        uninstall
        ;;
    --help)
        show_help
        ;;
    *)
        install
        ;;
esac
echo ""
popd > /dev/null
exit 0


