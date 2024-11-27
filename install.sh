#!/usr/bin/env bash

CURR_FOLDER="$(dirname "$0")"
pushd $CURR_FOLDER > /dev/null
SOURCE_FOLDER="$(pwd)/resources"
DESTINATION_FOLDER="$HOME/.mio"
VERSION="default"

function show_help(){
    echo -e "\nSYNOPSIS\n\tinstall.sh [--help] [--remove]\n"
    echo -e "\nDESCRIPTION\n\tThe following options are available:"
    echo -e "\n\t--help      show this help"
    echo -e "\t--remove    (uninstall) remove resources  linked to the ~/.lnav/formats/installed  folder\n"
}

function set_version(){
  GERRIT_VERSIONS=(`ls $SOURCE_FOLDER`)
  INDEX=1
  echo -e "\nYou are about to install default formats and scripts, valid for most Gerrit versions."
  echo -e "Specific formats for the following Gerrit versions are supported: \n"
  for i in "${GERRIT_VERSIONS[@]}"; do
    echo -e "\t${INDEX})\t$i"
    let INDEX=${INDEX}+1
  done
  echo ""
  read -p "Do you want to support a specific Gerrit version ?  (1 - ${#GERRIT_VERSIONS[@]} , enter to accept defaults)" veridx
  VERSION="${GERRIT_VERSIONS[$veridx -1]}"
}

function uninstall(){
  echo "uninstall"
}

function install(){
  mkdir -p "$DESTINATION_FOLDER"
  set_version
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
popd > /dev/null
exit 0


