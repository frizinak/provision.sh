#! /bin/bash
set -e

################################################################################
#################################### DOCTL #####################################
################################################################################
doctlversion="1.4.0"
doctlcfg="$HOME/.doctlcfg"
doctl="doctl/doctl"
if [ ! -f "${doctl}" ] || [ "$(cat "${doctl}.version" 2>/dev/null)" != "$doctlversion" ]; then
    mkdir doctl 2>/dev/null || true
    url=
    case "$(uname)" in
        *inux)
            url="https://github.com/digitalocean/doctl/releases/download/v${doctlversion}/doctl-${doctlversion}-linux-amd64.tar.gz"
            ;;
        *arwin)
            url="https://github.com/digitalocean/doctl/releases/download/v${doctlversion}/doctl-${doctlversion}-darwin-10.6-amd64.tar.gz"
            ;;
        *)
            echo "Unknown uname: $(uname)"
            exit 2
            ;;
    esac
    echo "Downloading doctl for $(uname)"
    if ! curl -L "${url}" 2>/dev/null | tar -z -C doctl -x doctl; then
        echo "Could not download version ${doctlversion}"
    fi

    if ! chmod +x "${doctl}" || ! "${doctl}" >/dev/null 2>&1;  then
        echo "Failed to download/extract doctl"
        exit 2
    fi

    echo "$doctlversion" > "${doctl}.version"
fi

if [ ! -f doctlcfg ] && [ ! -f "${doctlcfg}" ]; then
    cat > doctlcfg <<EOF
access-token: <your-digitalocean-api-token>
output: text
EOF
    echo "No doctlcfg file found, please fill in your api token in $(pwd)/doctlcfg"
    exit 2
fi

if [ -f doctlcfg ]; then doctlcfg=doctlcfg; fi

################################################################################
##################################### API ######################################
################################################################################
run () {
    "${doctl}" --config "${doctlcfg}" compute $@
    return $?
}

