#!/bin/sh

CHECKFILE=/maxminddb.check

test -f "${CHECKFILE}" && find "${CHECKFILE}" -mtime 7 -delete

if test ! -f "${CHECKFILE}"
then
#    mkdir -p /usr/share/GeoIP
#    curl -s http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz | gunzip -c > /usr/share/GeoIP/GeoIP.dat
#    curl -s http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz | gunzip -c > /usr/share/GeoIP/GeoIP.dat
    /bin/sh /etc/periodic/weekly/libmaxminddb && touch "${CHECKFILE}"
fi


if [ $# -eq 0 ]; then
    /usr/local/sbin/gdnsd -fx start
fi

exec "$@"
