#!/bin/bash     

#Compatibility opts
export LC_ALL=C
shopt -s dotglob

#Vars
_checking=false
_help=false
_workdir=""
_backupdir=""

#Helper functions for use of _checking
function cpHelper(){
    echo "cp -a $1 $2"
    if ! $_checking 
    then
        cp -a "$1" "$2"
    fi
}

function mkdirHelper(){
    echo "mkdir $1"
    if ! $_checking 
    then
        mkdir "$1"
    fi
}

function rmHelper(){
    echo "rm $1"
    if ! $_checking
    then
        rm "$1"
    fi
}

#Argument and flag parsing
while getopts ":ch" flag
do 
    case $flag in
        c) 
            _checking=true ;;
        h) 
            _help=true ;;
        ?)
            echo "Invalid option -$OPTARG: aborting backup"
            exit 1 ;;
    esac
done

#Strip flags and argument flags from argument list
shift $(($OPTIND - 1))

if $_help
then
    echo "Usage: backup_files [-c] workingDir backupDir"
    exit 0
fi

if [[ ! -d "$1" ]]
then
    echo "no such work diretory to backup" 
    exit 1
fi

#Resolve full paths
workdir=$(realpath "$1")
backupdir=$(realpath "$2")

#Check if backupDir is a subdirectory of workingDir
if [[  "${backupdir##$workdir}" != "$backupdir" ]]
then
    echo "Error: Backup directory is a sub-directory of working directory"
    exit 1
fi

#Create backupDir if needed
if [[ ! -d "$backupdir" ]]
then
    mkdirHelper $backupdir
fi

for fpath in "$workdir"/*
do
    fname=$(basename "$fpath")
    if [[ ! -f "$fpath" ]]
    then
        continue
    fi

    if [[ ! -f "$backupdir/$fname" ]] || [[ "$fpath" -nt "$backupdir/$fname" ]]
    then
        cpHelper "$fpath" "$backupdir/$fname"    
    elif [[ "$fpath" -ot "$backupdir/$fname" ]]
    then
        echo "WARNING"
    fi
done

for fpath in "$backupdir"/*
do
    fname=$(basename "$fpath")
    if [[ ! -f "$workdir/$fname" ]]
    then 
        rmHelper "$fpath"
    fi
done 

echo "BACKUP DONE"
exit 0 #Made with love by Igor Baltarejo & Gonçalo Almeida
