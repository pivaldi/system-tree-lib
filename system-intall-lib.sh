#!/bin/bash

CDIR=$(dirname "$BASH_SOURCE")

. "${CDIR}/lib/bsfl/lib/bsfl.bash" || exit 1

function error() {
    >&2 msg_error "$1"
}

function abort() {
    >&2 error 'Process aborted !'
    exit 1
}

[ -z "$PROJECT_ROOT_DIR" ] && {
    >&2 error 'The environment variable PROJECT_ROOT_DIR is not defined.'
    >&2 error 'This is the absolute directory where lives the system-tree project,'

    abort
}

[ -z "$SYSTEM_TREE_PATH" ] && {
    readonly SYSTEM_TREE_PATH="/system-tree/tree"
}

function info() {
    msg_info "$1"
}

function warn() {
    msg_warning "$1"
}

function nothing_to_do() {
    info "Nothing to do : $1"
}

function is_symlinck() {
    file --mime-type -b "$1" | grep -q 'inode/symlink'
}

function is_directory() {
    file --mime-type -b "$1" | grep -q 'inode/directory'
}

function is_file() {
    [ -f "$1" ] && ! is_symlinck "$1"
}

function create_parent_dir_if_needed() {
    PARENT="$(dirname $1)"

    [ -d "$PARENT" ] || {
        mkdir -p "$PARENT" && info "${BASH_SOURCE[0]}:$LINENO Directory '${PARENT}' created." || exit 1
    }

}

# ## Import a file or a directory (a resource) from the system to the system tree directory
# function import_resource_into_system_tree_if_needed() {
#     SYSTEM_TREE_RESOURCE="${SYSTEM_TREE_PATH}${1}"

#     [ -e "$SYSTEM_TREE_RESOURCE" ] || {
#         info "${BASH_SOURCE[0]}:$LINENO $SYSTEM_TREE_RESOURCE does not exist in the system-tree directory."
#         echo 'Trying to import it...'
#         is_symlinck "$1" && {
#             warn "${BASH_SOURCE[0]}:$LINENO $1 is a symlick, this script does not import symlincks in system-tree."
#             warn 'Do it yourself...'
#             return 0
#         }

#         create_parent_dir_if_needed "$SYSTEM_TREE_RESOURCE"
#         mv "$1" "$SYSTEM_TREE_RESOURCE" || exit 1
#     }
# }

# Symlinck ABSOLUTE path $1 (a file or au directory) from $SYSTEM_TREE_PATH
function symlinck() {
    # Remove trailing /
    local THEPATH=${1%/}
    local OLD=
    # import_resource_into_system_tree_if_needed "$THEPATH"

    SYSTEM_TREE_RESOURCE="${SYSTEM_TREE_PATH}${THEPATH}"

    [ -e "$THEPATH" ] && {
        [ "$THEPATH" -ef "$SYSTEM_TREE_RESOURCE" ] && {
            nothing_to_do "${BASH_SOURCE[0]}:$LINENO $THEPATH already symlinked to $SYSTEM_TREE_RESOURCE"
            return 1
        } || {
            DATE="$(date '+%Y-%m-%d_%H:%M:%S')"
            OLD="${THEPATH}_old_42--${DATE}"
            mv "$THEPATH" "$OLD" && warn "${BASH_SOURCE[0]}:$LINENO Created bck $OLD" || exit 1
        }
    }

    ln -s "$SYSTEM_TREE_RESOURCE" "$THEPATH" && info "${BASH_SOURCE[0]}:$LINENO Symlinck '$THEPATH' to '$SYSTEM_TREE_RESOURCE' created" || exit 1

    { [ ! -z $OLD ] && [ -d "${OLD}" ]; } && { ## Non vide et répertoire
        ## on synchronise l'ancien rep avec le nouveau pour récupérer les fichiers
        ## qui ne sont pas dans le rep du system tree
        info "${BASH_SOURCE[0]}:$LINENO [OBSOLETE] Synchronize ${OLD}/ to ${SYSTEM_TREE_RESOURCE}/"
        warn "${BASH_SOURCE[0]}:$LINENO [OBSOLETE] Not a good think to synchronize ${OLD}/ to ${SYSTEM_TREE_RESOURCE}/"
        rsync --ignore-existing -av "${OLD}/" "${SYSTEM_TREE_RESOURCE}/"
    }
}

# Symlinck recursively all files and only the files
# from $SYSTEM_TREE_PATH keeping the directories hierarchies
function recursive_symlinck_files_from_system_tree() {
    local MSG="Recursively symlincking all files from ${SYSTEM_TREE_PATH}"
    info $MSG
    files=$(find -L "$SYSTEM_TREE_PATH" -type f -print)

    local IFS=$(echo -en "\n\b")
    for file in $files; do
        ABS_PATH=$(echo $file | sed -e "s#^${SYSTEM_TREE_PATH}##1")
        symlinck "$ABS_PATH"
    done
}
