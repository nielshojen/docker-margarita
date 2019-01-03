#!/bin/bash
set -e

if [[ $LOCAL_URL ]]; then

/bin/cat <<EOF > /margarita/preferences.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>LocalCatalogURLBase</key>
  <string>${LOCAL_URL}</string>
  <key>UpdatesMetadataDir</key>
  <string>/reposado/metadata</string>
  <key>UpdatesRootDir</key>
  <string>/reposado/html</string>
</dict>
</plist>
EOF

fi

: "${APACHE_CONFDIR:=/etc/apache2}"
: "${APACHE_ENVVARS:=$APACHE_CONFDIR/envvars}"
if test -f "$APACHE_ENVVARS"; then
	. "$APACHE_ENVVARS"
fi

# Apache gets grumpy about PID files pre-existing
: "${APACHE_PID_FILE:=${APACHE_RUN_DIR:=/var/run/apache2}/apache2.pid}"
rm -f "$APACHE_PID_FILE"

exec apache2 -DFOREGROUND "$@"
