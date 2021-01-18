#! /bin/sh
#------------------------------------------------------------
# This is a fork of https://share.zabbix.com/cat-app/web-servers/ssl-certificates-check-4-4
#Modified by  Fabrizio Grasso https://github.com/fabryx87
#------------------------------------------------------------

DEBUG=0
if [ $DEBUG -gt 0 ]
then
    exec 2>>/tmp/sslcheckscript.log
    set -x
fi

f=$1
host=$2
port=$3
proto=$4

if [ -n "$proto" ]
then
    starttls="-starttls $proto"
fi

if [ -z "$port" ]
then
    port="443"
else
    port=$3
fi

case $f in
-d)
end_date=`openssl s_client -servername $host -host $host -port $port -showcerts $starttls -prexit </dev/null 2>/dev/null |
          sed -n '/BEGIN CERTIFICATE/,/END CERT/p' |
          openssl x509 -text 2>/dev/null |
          sed -n 's/ *Not After : *//p'`

if [ -n "$end_date" ]
then
    end_date_seconds=`date '+%s' --date "$end_date"`
    now_seconds=`date '+%s'`
        difference=`echo "scale=2; ( $end_date_seconds - $now_seconds )/(60*60*24)" | bc`
        echo ${difference}
#printf "%.0f\n" $(echo "scale=2; ( $end_date_seconds - $now_seconds )/(60*60*24)" | bc)
fi
;;

-i)
issue_dn=`openssl s_client -servername $host -host $host -port $port -showcerts $starttls -prexit </dev/null 2>/dev/null |
          sed -n '/BEGIN CERTIFICATE/,/END CERT/p' |
          openssl x509 -text 2>/dev/null |
          sed -n 's/ *Issuer: *//p'`

if [ -n "$issue_dn" ]
then
    issuer=`echo $issue_dn | sed -n 's/.*CN = *//p'`
    echo ${issuer}
else
    echo "Certificate Issuer not found..."
fi
;;
-w)
when_expire=`date -d "$(echo | openssl s_client -connect "$host":$port 2>/dev/null |
        openssl x509 -noout -enddate |
         sed 's/^notAfter=//')" "+%s"`
if [ -n "$when_expire" ]
then
        date_end=`echo $when_expire`
        echo ${date_end}
else
        echo "Date not found"
fi
;;
-c)
cipher=`openssl s_client -connect "$host":$port -cipher ALL </dev/null 2>/dev/null |
                                sed -n '/New/,/---/p' |
                                grep New | awk -F ',' '{print $3}' |
                                sed -r 's/^ Cipher is //'`
if [ -n "$cipher" ]
then
        script_cipher=`echo $cipher`
        echo ${script_cipher}
else
        echo "Cipher not found"
fi
;;
-z)
certificate=`openssl s_client -connect "$host":$port -cipher ALL </dev/null 2>/dev/null |
                                sed -n '/New/,/---/p' |
                                grep New | awk -F ',' '{print $2}'`
if [ -n "$certificate" ]
then
        script_certificate=`echo $certificate`
        echo ${script_certificate}
else
        echo "Certificate not found"
fi
;;
*)
echo "usage: $0 [-c|-i|-d|-w] hostname (port) (proto)"
echo "    -i Show Issuer"
echo "    -d Show valid days remaining"
echo "    -w show expire date"
echo "    -c show Chiper information"
echo "    -z show certificate information"

;;
esac
