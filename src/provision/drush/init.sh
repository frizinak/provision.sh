#! /bin/bash
help_text <<EOF
Drush for the webuser
EOF

install composer

su $webuser -c '
if [ ! -f $HOME/.config/composer/vendor/bin/drush ] || cat $HOME/.config/composer/composer.json | grep "drush" | grep -v 9; then
    composer global require drush/drush:^9.0;
fi
'

set_line "/home/${webuser}/.bashrc" \
    'PATH=$PATH:$HOME/.config/composer/vendor/bin'

ensure_dir "/home/${webuser}/.drush"

cat > "/home/${webuser}/.drush/drushrc.php" <<EOF
<?php
\$_SERVER['APP_ENV'] = 'local';
EOF
