# Zabbix-SSL-certificate-5.2
this is a fork of https://share.zabbix.com/cat-app/web-servers/ssl-certificates-check-4-4

Information:

There is a basic HTTPS down check and trigger. There are no triggers for the issuer check.
The basic HTTPS check fires every 90 seconds. Issuer and validity check every 6 hours (21600 seconds). This script is modified with suggestions from the comments at Romans version of the script and to make it as simple as possible. The following macro's are added to tweak the triggers of this template. Especially for certificates from LetsEncrypt is usefull to tweak these macro's:

{$SNI_TIME_AVG} = Average Trigger (Default value: 14 days)

{$SNI_TIME_HIGH} = High Trigger (Defaut value: 7 days)

{$SNI_TIME_INF} = Information Trigger (Default value: 45 days)

{$SNI_TIME_NC} = Not Classified Trigger (Default value: 60 days)

{$SNI_TIME_WARN} = Warning Trigger (Default value: 30 days)

{$SSL_PORT} = SSL port (Default value: 443)

{$SNI} = Hostname or website name to check (Default value: {HOST.NAME} (Zabbix hostname macro)

usage on the shell: ./zext_ssl_cert.sh [-c|-i|-d|-w] hostname (port) (proto)
    -i Show Issuer
    -d Show valid days remaining
    -w show expire date
    -c show Chiper information
    -z show certificate information
