#! /bin/bash
set -e
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
    echo 'success'
    exit 0
fi

echo 'FAILED!';
exit $stat
# START TAR #
