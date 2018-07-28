#!/bin/bash

# Interactive script to launch applications
#
# Uses a modified version of dmenu to gain iteractivity, a configuration file provides options on how the script should be launched, with a file, directory, or with nothing. If a file or directory is requested for the application launch the script can behave as a simple file browser still powered by dmenu.

## dmenu
# The dmenu used with this script is modified so that reading from STDIN is non blocking also several parameters have been added to use in an interactive way, such as a clear and stop command. The modified dmenu or patches to modify dmenu can be downloaded from:

## Configuration File
# File has 6 fields, all but the first field may be empty. Fields are deliminated by the config_delim variable, which by default is | this may be specified in the script or by the user at runtime. Fields values have their leading and trailing whitespace stripped, but internal whitespace remains intact.  Empty fields are assumed to be false, true field are denoted by "true" or "t" anything else in boolean fields is considered false.
#
### Fields
#
# app_name          - STR: name of application displayed in menu
# with_path         - BOOL: if true signals that the menu should act as a file browser to select a path
# select_dir        - BOOL: if true then the selected path should be a directory, otherwise path must be a file file.
# show_hidden       - BOOL: if true hidden files/folders are displayed
# base_path         - PATH: path where menu browser starts from, defaults to users home
# launch_command    - CMD: command to execute when app is selected

## Hacking
# the interactive REPL using dmenu is achieved using a modified version of dmenu and named pipes. The loop is initailized by sending the initial menu entries to a file descriptor of the named pipe and redirecting the file descriptor to dmenu STDIN. Inside the loop execution waits for new values from dmenu STDOUT, values are generated when a menu entry is selected from within dmenu. The value from dmenu is processed and new commands are sent to dmenu via the already open named pipe file descriptor.
#

# user variables
config_file=~/.config/herbstluftwm/launcher/launcher-menu.txt
config_delim='|'
command_prefix="herbstclient spawn"

# config variables
select_dir=""
hidden_files=""
file_extensions=""
base_path=""
launch_command=""
app_name=""

# internal variables
app_selected="false"
target=""

usage="Usage: $(basename "$0") [-he][-f PATH][-x CMD][-d CHAR]
Interactive script to launch applications

default menu config file path:  $config_file
default command prefix:         $command_prefix

Options:
    -h          show this help text then exit
    -e          use 'exec' as command prefix
    -f PATH     path to menu-config file
    -x CMD      command to use as prefix for app launching
    -d CHAR     delimiter used for parsing the configuration file

For more information please see comments at top of script.
Script path: $( cd "$( dirname "${BASH_SOURCE[0]}" )" && echo $(pwd)/$(basename "$0"))
"


while getopts ":hf:ex:d:" opt; do
    case $opt in
        h)
            echo "$usage"
            ;;
        e)
            command_prefix="exec"
            ;;
        f)
            config_file="$OPTARG"
            ;;
        x)
            command_prefix="$OPTARG"
            ;;
        d)
            config_delim="$OPTARG"
            ;;
        \?)
            echo "invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# config file path must be a file
if ! [[ -f "$config_file" ]]; then
    echo "Invalid configuration file: $config_file, path must be a file" >&2
    exit 1
fi

# make sure the delimiter is a single char
if ! [[ ${#config_delim} -eq 1 ]]; then
    echo "Config file delimiter $config_delim is not valid, may only be 1 character"
    exit 1
fi


# path of named pipe
pipe=/tmp/dmenu-input

# check if something exists at the pipes location
if [[ -a "$pipe" ]]; then
    if [[ -p "$pipe" ]]; then
        # if pipe already exists, drain it
        dd if="$pipe" iflag=nonblock of=/dev/null 2>&1 > /dev/null
    else
        # if file exists where pipe should be, delete it
        rm -r "$pipe"
    fi
else
    # if pipe does not exists and there are no conflicts, create it
    mkfifo "$pipe"
fi

# create file descriptor for pipe
exec 3<> "$pipe"


# print list of files or directories based on application.txt flags to dmenu. Clears old dmenu input, relies on global variables: $target $hidden_files $select_dir
function update_dmenu
{
    echo "CLEAR" >&3

    # generate different menu entries depending on which flags are set: hidden_files, select_dir
    if [[ "$hidden_files" = "true" ]]; then
        if [[ "$select_dir" = "true" ]]; then
            { echo "."; echo ".."; ls -d1a "$target"/*/; } | xargs basename -a >&3
        else
            if [[ ! -z "$file_extensions" ]]; then
                { echo ".."; ls -1a "$target" | grep -E "\.($file_extensions)$"; } >&3
            else
                { echo ".."; ls -1a "$target"; } >&3
            fi
        fi
    else
        if [[ "$select_dir" = "true" ]]; then
            { echo "."; echo ".."; ls -d1 "$target"/*/; } | xargs basename -a >&3
        else
            if [[ ! -z "$file_extensions" ]]; then
                { echo ".."; ls -1d "$target"/*/ | grep -oE "[^\/]+\/$"; ls -1 "$target" | grep -E "\.($file_extensions)$"; } >&3
            else
                { echo ".."; ls -1 "$target"; } >&3
            fi
        fi
    fi

}

# print list of application names after stripping comments
cat "$config_file" | grep -v "^#" | grep -oP '^[^\'$config_delim']+' >&3

# first iteration picks application to use, subsiquent iteration are to pick a file/directory if the application requests it
while read line; do
    # this first if statement should only be executed on the first iteration, on that iteration only this statement should execute, all following statements should be skipped
    if [[ "$app_selected" = "false" ]]; then
        # get relavenet line of configuration from config file and strip whitespace surrint seperator
        app_line=$(cat "$config_file" | grep "^${line}" | sed -r 's/\s*\'$config_delim'\s*/\'$config_delim'/g')

        # read configuration options for application
        IFS="$config_delim" read app_name with_path select_dir hidden_files base_path file_extensions launch_command <<< $(echo $app_line)

        # if a base path has not been specified use the users home
        if [[ -z "${base_path// }" ]]; then
            base_path=$HOME
        fi

        # if a launch command has not been specified use the app name
        if [[ -z "${launch_command// }" ]]; then
            launch_command="$app_name"
        fi

        if [[ ! -z "$file_extensions" ]]; then
            file_extensions="${file_extensions// /|}"
        fi

        # expand ~ to home directory
        launch_command="${launch_command/#\~/$HOME}"
        if [[ "$with_path" = "true" ]]; then
            # if a file/directory path is requested for the application start, save relavent configuration and continue

            app_selected="true"

            # epand ~ to home directory
            target="${base_path/#\~/$HOME}"

            # update dmenu and skip the last remainder of the REPL, this first block will be skipped on further iterations.
            update_dmenu
            continue
        else
            # if no file/directory is requested for appliation start, exit dmenu and start the application, and exit script
            echo "STOP" >&3
            break
        fi
    fi

    # update target path
    target="${target}/${line}"

    # use current selection if directory specified and the current directory (.) is selected or if the current selection has no subdirectories and is itself a directory
    if [[ "$select_dir" = "true" ]] && [[ -d "$target" ]]  && ( [[ "$line" = "." ]] || ! ls -d -l $target/*/ > /dev/null 2>&1 ); then
        echo "STOP" >&3
        eval $command_prefix $launch_command "$target" >&2
        break

    # use current selection if file specified and the current selection is a directory
    elif [ -f "$target" ]; then
        echo "STOP" >&3
        eval "$command_prefix" "$launch_command" "$target"
        break
    fi

    update_dmenu

# get input continously from dmenu, dmenu in turn is getting input from the named pipe which is fed in loop
done < <(dmenu -l 20 -p "prompt: " -I -x 646 -y 74 -w 1268 -ct "CLEAR" -st "STOP" <&3)

# close pipe file descriptor
exec 3>&-

# delete pipe
rm /tmp/dmenu-input
