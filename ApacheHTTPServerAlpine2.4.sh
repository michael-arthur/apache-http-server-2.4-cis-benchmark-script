#!/bin/ash

cd /usr/local/apache2/benchmark

a="Apache_HTTP_Server_2.4.txt"

#hard coding  location of httpd file
loc="/usr/local/apache2/conf/httpd.conf"
read -t 3 loc
y=$(ls -al /usr/local/apache2/conf/httpd.conf 2>&1)
var=$(echo $y | grep "No such file")

echo -e "\n ===========================================================================================\n" >> $a
echo -e "\n|                    Apache HTTP Server 2.4 CIS Benchmark v1.5.0 Script                     |\n" >> $a
echo -e "\n ===========================================================================================\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n1.2 Ensure the Server Is Not a Multi-Use System\n" >> $a 
chkconfig --list | grep ':on' >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.1 Ensure Only Necessary Authentication and Authorization Modules Are Enabled\n" >> $a
httpd -M | egrep 'auth._' >> $a
httpd -M | egrep 'ldap' >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.2 Ensure the Log Config Module Is Enabled\n" >> $a
httpd -M | grep log_config >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.3 Ensure the WebDAV Modules Are Disabled\n" >> $a
httpd -M | grep ' dav_[[:print:]]+module' >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.4 Ensure the Status Module Is Disabled\n" >> $a
httpd -M | egrep 'status_module' >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.5 Ensure the Autoindex Module Is Disabled\n" >> $a
httpd -M | grep autoindex_module >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.6 Ensure the Proxy Modules Are Disabled\n" >> $a
httpd -M | grep proxy_ >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.7 Ensure the User Directories Module Is Disabled\n" >> $a
httpd -M | grep userdir_ >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.8 Ensure the Info Module Is Disabled\n" >> $a
httpd -M | egrep 'info_module' >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n2.9 Ensure the Basic and Digest Authentication Modules are Disabled\n" >> $a
httpd -M | grep auth_basic_module >> $a
httpd -M | grep auth_digest_module >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.1 Ensure the Apache Web Server Runs As a Non-Root User\n" >> $a
grep -i '^User' $APACHE_PREFIX/conf/httpd.conf >> $a
grep -i '^Group' $APACHE_PREFIX/conf/httpd.conf >> $a
grep '^UID_MIN' /etc/login.defs >> $a
id apache >> $a
ps axu | grep httpd | grep -v '^root' >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.2 Ensure the Apache User Account Has an Invalid Shell\n" >> $a
grep apache /etc/passwd >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.3 Ensure the Apache User Account Is Locked\n" >> $a
passwd -S apache >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.4 Ensure Apache Directories and Files Are Owned By Root\n" >> $a
find $APACHE_PREFIX \! -user root -ls >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.5 Ensure the Group Is Set Correctly on Apache Directories and Files\n" >> $a
find $APACHE_PREFIX -path $APACHE_PREFIX/htdocs -prune -o \! -group root -ls >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.6 Ensure Other Write Access on Apache Directories and Files Is Restricted\n" >> $a
find -L $APACHE_PREFIX \! -type l -perm /o=w -ls >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.7 Ensure the Core Dump Directory Is Secured\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.8 Ensure the Lock File Is Secured\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.9 Ensure the Pid File Is Secured\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.10 Ensure the ScoreBoard File Is Secured\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.11 Ensure Group Write Access for the Apache Directories and Files Is Properly Restricted\n" >> $a
find -L $APACHE_PREFIX \! -type l -perm /g=w -ls >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.12 Ensure Group Write Access for the Document Root Directories and Files Is Properly Restricted\n" >> $a
GRP=$(grep '^Group' $APACHE_PREFIX/conf/httpd.conf | cut -d' ' -f2)
find -L $DOCROOT -group $GRP -perm /g=w -ls >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n3.13 Ensure Access to Special Purpose Application Writable Directories is Properly Restricted\n" >> $a
echo -e "\nManual Check Required: Single Purpose Directory\n" >> $a
echo -e "\nOutside the Configured Web DocumentRoot\n" >> $a
# Set the WR_DIR to the writable directory such as the example shown below
WR_DIR=/var/phptmp/sessions
# DOCROOT is the DocmentRoot directory for the web site or virtual host.
DOCROOT=$(grep -i '^DocumentRoot' $APACHE_PREFIX/conf/httpd.conf | cut -d' ' -f2 | tr -d '\"')
# Get Inode number of the writable Directory
INUM=$(stat -c '%i' $WR_DIR)
# Verify the directory is not found (No output = Not found)
find -L $DOCROOT -inum $INUM >> $a
echo -e "\nOwned by the root User or an Administrator Account\n" >> $a
stat -c '%U' $WR_DIR/ >> $a
echo -e "\nNot writable by Other\n" >> $a
find $WR_DIR/ -perm /o=w -ls >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n4.1 Ensure Access to OS Root Directory Is Denied By Default\n" >> $a
perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $APACHE_PREFIX/conf/httpd.conf | grep "Require all denied" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n4.2 Ensure Appropriate Access to Web Content Is Allowed\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n4.3 Ensure OverRide Is Disabled for the OS Root Directory\n" >> $a
perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $APACHE_PREFIX/conf/httpd.conf | grep "AllowOverride None" >> $a
perl -ne 'print if /^ *<Directory *\//i .. /<\/Directory/i' $APACHE_PREFIX/conf/httpd.conf | grep "AllowOverrideList" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n4.4 Ensure OverRide Is Disabled for All Directories\n" >> $a
grep -i AllowOverride $APACHE_PREFIX/conf/httpd.conf >> $a
grep -i AllowOverrideList $APACHE_PREFIX/conf/httpd.conf >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.1 Ensure Options for the OS Root Directory Are Restricted\n" >> $a
perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $APACHE_PREFIX/conf/httpd.conf | grep "Options None" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.2 Ensure Options for the Web Root Directory Are Restricted\n" >> $a
perl -ne 'print if /^ *<Directory */i .. /<\/Directory/i' $APACHE_PREFIX/conf/httpd.conf | grep "Options" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.3 Ensure Options for Other Directories Are Minimized\n" >> $a
grep -i -A 12 '<Directory[[:space:]]' $APACHE_PREFIX/conf/httpd.conf | grep "Options" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.4 Ensure Default HTML Content Is Removed\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.5 Ensure the Default CGI Content printenv Script Is Removed\n" >> $a
rm $APACHE_PREFIX/cgi-bin/printenv
echo -e "\nManual Check should also be done\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.6 Ensure the Default CGI Content test-cgi Script Is Removed\n" >> $a
rm $APACHE_PREFIX/cgi-bin/test-cgi
echo -e "\nManual Check should also be done\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.7 Ensure HTTP Request Methods Are Restricted\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "LimitExcept" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.8 Ensure the HTTP TRACE Method Is Disabled\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "TraceEnable" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.9 Ensure Old HTTP Protocol Versions Are Disallowed \n" >> $a
./configure --enable-rewrite.
cat /usr/local/apache2/conf/httpd.conf | grep "RewriteEngine On\|RewriteCond \%{THE_REQUEST}\|RewriteRule \.\* \- \[F\]\|RewriteOptions Inherit" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n5.10 Ensure Access to .ht* Files Is Restricted\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep -e "^<FilesMatch \"\^\\\.ht\">\|Require all denied\|<\/FilesMatch>" -n >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n6.1 Ensure the Error Log Filename and Severity Level Are Configured Correctly\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "LogLevel\|ErrorLog" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n6.3 Ensure the Server Access Log Is Configured Correctly\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "^LogFormat\|^CustomLog" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n6.4 Ensure Log Storage and Rotation Is Configured Correctly\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n6.5 Ensure Applicable Patches Are Applied\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.1 Ensure mod_ssl and/or mod_nss Is Installed\n" >> $a
sudo httpd -M | egrep 'ssl_module|nss_module' >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.2 Ensure a Valid Trusted Certificate Is Installed\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.3 Ensure the Server's Private Key Is Protected\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "^SSLCertificateFile\|^SSLCertificateKeyFile" -n >> $a
temp=$(cat /usr/local/apache2/conf/httpd.conf | grep "^SSLCertificateKeyFile" | cut -d " " -f 2)
ls -al $temp >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.4 Ensure Weak SSL Protocols Are Disabled\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "^SSLProtocol" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.5 Ensure Weak SSL/TLS Ciphers Are Disabled\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.6 Ensure Insecure SSL Renegotiation Is Not Enabled\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "^SSLInsecureRenegotiation" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.7 Ensure SSL Compression is not Enabled\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "^SSLCompression" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.8 Ensure Medium Strength SSL/TLS Ciphers Are Disabled\n" >> $a
echo -e "\nManual Check Required\n" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n7.9 Ensure All Web Content is Accessed via HTTPS\n" >> $a
echo -e "\n Enter the list of all apache configuration files in the following format :\n"
echo -e "\n Eg: conf /etc/httpd/conf.d /etc/httpd/conf_dir2"
#Replace the following directory list with the appropriate list.
#CONF_DIRS="/etc/httpd/conf /etc/httpd/conf.d /etc/httpd/conf_dir2 . . ."
read -t 3 /usr/local/apache2/conf/
CONFS=$(find /usr/local/apache2/conf/ -type f -name '*.conf' )
#Search for Listen directives that are not port :443 or https
IPS=$(egrep -ih '^\s*Listen ' $CONFS | egrep -iv '(:443\b)|https' | cut -d' ' -f2)
#Get host names and ports of all of the virtual hosts
VHOSTS=$(egrep -iho '^\s*<VirtualHost .*>' $CONFS | egrep -io '\s+[A-Z:.0-9]+>$' | tr -d ' >')
URLS=$(for h in $LIPADDR $VHOSTS ; do echo "http://$h/"; done)
#For each of the URL�s test with curl, and truncate the output to 300 characters
for u in $URLS ; do echo -e "\n\n\n=== $u ==="; curl -fSs $u | head -c 300 ; done >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n8.1 Ensure ServerTokens is Set to Prod or ProductOnly\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "^ServerTokens" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n8.2 Ensure ServerSignature Is Not Enabled\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "^ServerSignature Off" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n9.1 Ensure the TimeOut Is Set to 10 or Less\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "Timeout" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n9.2 Ensure KeepAlive Is Enabled\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "KeepAlive" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n9.3 Ensure MaxKeepAliveRequests is Set to a Value of 100 or Greater\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "MaxKeepAliveRequests" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n9.4 Ensure KeepAliveTimeout is Set to a Value of 15 or Less\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "KeepAliveTimeout" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n9.5 Ensure the Timeout Limits for Request Headers is Set to 40 or Less\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "RequestReadTimeout" >> $a

echo -e "\n==========================================================================================\n" >> $a
echo -e "\n9.6 Ensure Timeout Limits for the Request Body is Set to 20 or Less\n" >> $a
cat /usr/local/apache2/conf/httpd.conf | grep "RequestReadTimeout" >> $a
echo -e "\n==========================================================================================\n" >> $a


exit