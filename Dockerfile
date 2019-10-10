FROM python:2.7-slim

EXPOSE 80
EXPOSE 8089

RUN apt-get update -qq
RUN apt-get install -y -qq apache2 apache2-utils curl libapache2-mod-wsgi wget apt-utils
RUN pip install -q flask
RUN mkdir -p /margarita /reposado/html /reposado/metadata
RUN mkdir -p /var/lock/apache2 /var/run/apache2
RUN curl -ksSL https://github.com/jessepeterson/margarita/tarball/master | tar zx
RUN cp -rf jessepeterson-margarita-*/* /margarita
RUN rm -f master
RUN curl -ksSL https://github.com/wdas/reposado/tarball/master | tar zx
RUN cp -rf wdas-reposado-*/code/reposadolib /margarita
RUN rm -f master /etc/apache2/sites-enabled/000-default.conf
RUN rm -rf jessepeterson-margarita-* wdas-reposado-*
RUN wget -P /tmp https://github.com/pusher/oauth2_proxy/releases/download/v4.0.0/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz
RUN tar -C /tmp -zxvf /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz
RUN rm /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1.tar.gz
RUN mv /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1/oauth2_proxy /usr/local/bin/oauth2_proxy
RUN rm -rf /tmp/oauth2_proxy-v4.0.0.linux-amd64.go1.12.1
RUN apt-get -y -qq remove --purge curl
RUN apt-get -y -qq autoremove --purge
RUN apt-get -qq clean
RUN a2enmod auth_digest authn_anon authn_dbd authn_dbm authn_socache authnz_fcgi authnz_ldap authz_dbd authz_dbm authz_groupfile authz_owner ssl
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY extras.conf /
COPY margarita.conf /etc/apache2/sites-enabled/
COPY margarita.wsgi /
COPY preferences.plist /margarita/
COPY start.sh /

RUN chown -R www-data:www-data /margarita /start.sh
RUN chmod -R ug+rws /margarita
RUN chmod g+x /start.sh

CMD ["/start.sh"]
