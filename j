#!/bin/sh

source config

# create journal dir if not existent
if [ ! -d "$JOURNAL_DIR" ]
then
    mkdir $JOURNAL_DIR
fi

COMMANDS="add:list:del"

cmd=""

if [ $# -eq 0 ]
then
    echo "No arguments supplied."
    # TODO SHOW HELP
    exit 0
else
    if [[ ":$COMMANDS:" == *:$1:* ]]
    then
        cmd=$1
        shift
    else
        echo "No command"
        echo "Args: $@"
    fi
fi

case $cmd in
    add)
        TITLE=""
        DUE=""
        while getopts ":t:d:" opt
        do
            case ${opt} in
                t)  
                    TITLE=$OPTARG
                    ;;
                d) 
                    DUE=$OPTARG
                    ;;
                \?)
                    echo "Invalid options. Ignoring them."
                    ;;
                :) 
                    echo "Invalid option: $OPTARG requires an argument"
                    exit 1
                    ;;
            esac
        done
        shift $((OPTIND -1))

        # generate filename
        FILE=$(date +"%Y-%m-%d_%H:%M:%S").txt

        # print unique identifier based on time
        echo "[" >> $JOURNAL_DIR/$FILE
        echo "date: $(date +"%Y-%m-%d_%H:%M:%S") |" >> $JOURNAL_DIR/$FILE
        echo "title: $TITLE |" >> $JOURNAL_DIR/$FILE
        echo "due: $DUE |" >> $JOURNAL_DIR/$FILE
        echo "]" >> $JOURNAL_DIR/$FILE

        # open file in vim for editing
        nvim -s vim.txt $JOURNAL_DIR/$FILE
        
        ;;
    list)
        let i=1
        printable=""
        for f in $(ls $JOURNAL_DIR/*.txt)
        do
            # file=$( echo $f | rev | cut -d "/" -f 1 | rev | cut -d "." -f 1)
            file=$(cat $f)
            # echo $file 
            file=${file#*[}; 
            file=${file%%]*}
            # echo $file
            date=$(echo $file | cut -d '|' -f 1 | cut -d ':' -f 2)
            title=$(echo $file | cut -d '|' -f 2 | cut -d ':' -f 2)
            due=$(echo $file | cut -d '|' -f 3 | cut -d ':' -f 2)
            printable="$printable$i\t$date\t$title\t$due\n"
            let ++i
        done
        echo -ne $printable | column -t -s '\t' 
        ;;
    *)
        echo "No command found"
        ;;
esac
