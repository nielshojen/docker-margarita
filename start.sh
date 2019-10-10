#!/bin/bash
set -e

if [[ -f "/etc/oauth2_proxy.cfg" ]]; then
    /bin/echo "Found oauth2 proxy config file ..."
    /bin/echo "Starting oauth2_proxy ..."
    /usr/local/bin/oauth2_proxy --upstream=http://0.0.0.0:8089
elif [[ ${OAUTH2_PROXY_COOKIE_SECRET} ]] && [[ ${OAUTH2_PROXY_EMAIL_DOMAINS} ]] && [[ ${OAUTH2_PROXY_CLIENT_SECRET} ]]; then
    /bin/echo "Starting oauth2_proxy with settings from env ..."
    /usr/local/bin/oauth2_proxy --upstream=http://0.0.0.0:8089
fi

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

if [[ $ADMIN_USER ]] && [[ $ADMIN_PASS ]]; then
/usr/bin/htpasswd -b -c /margarita/.htpasswd ${ADMIN_USER} ${ADMIN_PASS}
/bin/cat <<EOF > /extras.conf
## Basic Authentication
 <Location />
   AuthType Basic
   AuthName "Authentication Required"
   AuthUserFile "/margarita/.htpasswd"
   Require valid-user
 </Location>
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
