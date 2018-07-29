#! /bin/bash
sed "1,/^# START TAR #$/d" "$0" | tar -xz
find provision -type f -exec chmod 600 {} \;
find provision -type d -exec chmod 700 {} \;
chmod 700 ./provision/setup.sh
cd provision
echo "Waiting for apt to stop"
while true; do
    if ! ps aux | grep apt | grep -v grep >/dev/null; then
        break
    fi
    sleep 2
done

./setup.sh $@
stat=$?

cd ..;
rm -rf provision
rm "$0";

if [ $stat -eq 0 ]; then
    echo
    echo -e '\033[1;30;42m         \033[0m'
    echo -e '\033[1;30;42m SUCCESS \033[0m'
    echo -e '\033[1;30;42m         \033[0m'
    exit 0
fi

echo
echo -e '\033[1;37;41m        \033[0m'
echo -e '\033[1;37;41m FAILED \033[0m'
echo -e '\033[1;37;41m        \033[0m'
exit $stat
# START TAR #
