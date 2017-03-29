#! /bin/bash
set -e

source 'do.sh'
source 'utils.sh'
################################################################################
##################################### HELP #####################################
################################################################################
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    cat <<EOF
$0 [name [suffix]]
EOF
    exit 0
fi

################################################################################
##################################### LIST #####################################
################################################################################
if [ "$1" == "-l" ] || [ "$1" == "--list" ]; then
    run image list-user
    exit $?
fi

################################################################################
#################################### DELETE ####################################
################################################################################
if [ "$1" == "-d" ] || [ "$1" == "--delete" ]; then
    run image delete "$2"
    exit $?
fi

################################################################################
################################### GLOBALS ####################################
################################################################################
dropletName=$1
suffix=$2
dropletID=
IFS=$'\n'

if [ "$suffix" == "" ]; then
    suffix="$(date +%Y-%m-%d--%H-%M)"
fi

getDropletID () {
    droplets=($(run droplet list --no-header | cut -f1,2 | grep "$dropletName"))

    while true; do
        local i=0
        for d in "${droplets[@]}"; do
            i=$(( i + 1 ))
            list "${i})" "${d}"
            echo
        done

        local selection=1
        if [ $i -gt 1 ]; then
            prompt 'Which key?'
            read selection
        fi

        selection=$(( selection - 1 ))
        dropletID=$(echo "${droplets[$selection]}" | grep -oE '^[0-9]+')
        dropletName=$(echo "${droplets[$selection]}" | cut -f2)
        if [ "${dropletID}" != "" ]; then
            break
        fi
    done
}

getDropletID

run droplet-action snapshot "${dropletID}" \
    --snapshot-name "${dropletName}-${suffix}" --wait
