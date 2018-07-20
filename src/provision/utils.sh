#! /bin/bash
################################################################################
#################################### GLOBAL ####################################
################################################################################
included=""
_indent_amount=4
_indent=-$_indent_amount

################################################################################
################################### UTILITY ####################################
################################################################################

# include name
include () {
    local name=$(echo $@ | cut -d' ' -f1- --output-delimiter='|')
    for i in $included; do
        if [ "${name}" == "${i}" ]; then
            return
        fi
    done
    included="${included} ${name}"
    echo "${name}" >> /var/provisioners

    _indent=$(( _indent + _indent_amount ))
    local pad=$(( 80 - _indent ))
    local format="\033[1;30;42m %${_indent}s%-${pad}s \033[0m\n"
    if [ $pad -lt 0 ]; then pad=0; fi
    printf "${format}" "" "${1} {"

    . "./${1}/init.sh" $@

    printf "${format}" "" "} ${1}"
    _indent=$(( _indent - _indent_amount ))
}

_indent () {
    for i in $(seq 0 $1); do
        if [ $i -ne 0 ]; then
            echo -en "  "
        fi
    done
}

# help_text <<EOF...EOF
help_text () {
    # dummy
    return 0
}

################################################################################
#################################### FILES #####################################
################################################################################
# set_line file line
set_line () {
    if ! cat "${1}" | grep "^${2}$" >/dev/null; then
        echo "${2}" >> "${1}"
    fi

    return $?
}

# replace_line file needle replacement
replace_line () {
    sed -i "s/${2}/${3}/" "${1}"
    set_line "${1}" "${3}"
}

# ensure_dir dir
ensure_dir () {
    mkdir -p "$1" 2>/dev/null || true
    if [ ! -d "$1" ]; then
        echo 'Could not create dir'
        return 1
    fi

    return 0
}

# template file key=value key=value...
template () {
    local template key val i
    template="$(cat "$1")"

    shift
    for i in "$@"; do
        key="$(echo "$i" | cut -d= -f1)"
        val="$(echo "$i" | cut -d= -f2)"
        template="$(echo "${template}" | awk '{ gsub("'"<${key}>"'","'"${val}"'",$0); print $0 }')"
    done

    echo "${template}"
}

################################################################################
##################################### APT ######################################
################################################################################
# apt_repo type repo
apt_repo () {
    if cat /etc/apt/sources.list.d/* | grep ^deb | grep "$2"  >/dev/null 2>&1; then
        return 0
    fi

    add-apt-repository --yes "$1:$2"
    apt-get update
}

# install pkg [pkg...]
install () {
    local list i
    for i in "$@"; do
        if ! dpkg --status "$i" >/dev/null 2>&1; then
            list="${list} ${i}"
        fi
    done

    if [ "$list" != "" ]; then
        apt-get install -y $list
    fi
}

################################################################################
##################################### USER #####################################
################################################################################
# create_user user pw
create_user () {
    if ! getent passwd "${1}" >/dev/null; then
        useradd -ms /bin/bash -d "/home/${1}" "${1}"
    fi

    if [ "${2}" != "" ]; then
        if passwd -S "${1}" | grep -e "${1} L" -e "${1} NP" >/dev/null; then
            echo "${1}:${2}" | chpasswd
        fi
    fi
}

# fix_user_perms user
fix_user_perms () {
    chown -R "${1}:${1}" "/home/${1}"
}

################################################################################
################################### SYSTEMD ####################################
################################################################################
# service template key=value key=value...
service () {
    local name
    name="$(basename "$1")"

    ensure_dir /usr/lib/systemd/system
    template "$@" > "/usr/lib/systemd/system/${name}"
    systemctl daemon-reload
    systemctl enable "${name}"
    systemctl restart "${name}"
}

native_service () {
    systemctl daemon-reload
    systemctl is-enabled "$1" || systemctl enable "$1"
    systemctl restart "$1"
}

