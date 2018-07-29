#! /bin/bash
help_text <<EOF
root:root localhost mysql install
EOF

install mariadb-server mariadb-client mariadb-common

native_service mysql.service
if mysql -e 'show databases;' &>/dev/null; then
    # read-only user
    mysql -e "GRANT SELECT ON *.* TO ro@'%' IDENTIFIED BY 'root'"

    mysql -e "UPDATE mysql.user SET Password=PASSWORD('${mysql_pw}'), plugin='' WHERE User = 'root'"
    mysql -e "DROP USER ''@'localhost'" 2>/dev/null || true
    mysql -e "DROP USER ''@'$(hostname)'" 2>/dev/null || true
    mysql -e "DROP DATABASE test" 2>/dev/null || true
    mysql -e "FLUSH PRIVILEGES"
fi

cat > "${home}/.my.cnf" <<EOF
[client]
user=root
password=${mysql_pw}
EOF
