#!/bin/bash
# Install WordPress Chinese version on Repl.it
# Copyright © by Shuxia All Rights Reserved.
# 2022/12/6 12:27
# 1. Create a new Repl.it as a PHP Web Server 
# 2. Update the replit.nix file to include the code in this repo
# 3. Restart the Repl
# 4. Run this command from the Replit shell:
#    bash <(curl -s https://raw.githubusercontent.com/siwovof/wordpress-zh_CN-on-replit/main/build.sh)

echo "Ready to install Wordpress in your Replit"

read -p "Continue? Enter Y to install and enter N to exit <Y/n>" prompt
if [[ $prompt == "N" || $prompt == "n" || $prompt == "No" || $prompt == "no" ]]; then
  exit 0
fi

#Make sure steps 1-3 are completed before installing Wordpress
if ! [ -x "$(command -v less)" ]; then
  echo 'Error: less is not installed. Please make sure you have updated the replit.nix file and restarted the Repl.' >&2
  exit 1
fi

if ! [ -x "$(command -v wp)" ]; then
  echo 'Error: wp-cli is not installed. Please make sure you have updated the replit.nix file and restarted the Repl.' >&2
  exit 1
fi

#Make sure we're in the right place!
cd ~/$REPL_SLUG

#remove default repl.it code file
rm ~/$REPL_SLUG/index.php

#Download Wordpress!
wp core download --locale=zh_CN

#SQLITE Plugin: Download, extract and cleanup sqlite plugin for WP
curl -LG https://raw.githubusercontent.com/sxbai/wordpress-zh_CN-on-replit/main/db.php > ./wp-content/db.php

#Create dummy config to be overruled by sqlite plugin
wp config create --skip-check --dbname=wp --dbuser=wp --dbpass=pass --extra-php <<PHP
\$_SERVER[ "HTTPS" ] = "on";
define( 'WP_HOME', 'https://$REPL_SLUG.$REPL_OWNER.repl.co' );
define( 'WP_SITEURL', 'https://$REPL_SLUG.$REPL_OWNER.repl.co' );
define ('FS_METHOD', 'direct');
define('FORCE_SSL_ADMIN', true);
PHP

# Get info for WP install
read -p "Enter your WordPress username: " username
while true; do
   read -s -p "Enter Wordpress password: " password
   echo
   read -s -p "Enter Wordpress password again: " password2
   echo
   [ "$password" = "$password2" ] && break
   echo "Please try again!"
done

read -p "Please enter Wordpress Email: " email
read -p "Please enter the title of the Wordpress site: " title

REPL_URL=$REPL_SLUG.$REPL_OWNER.repl.co

# Install Wordpress
wp core install --url=$REPL_URL --title=$title --admin_user=$username --admin_password=$password --admin_email=$email

echo "Congratulations!!!"
echo "Your new WordPress site is now setup!"
echo "Web address: https://$REPL_URL"
echo "Admin address: https://$REPL_URL/wp-admin"
echo "Administrator account: $username"
echo "admin password: $password"
echo "Click the Run button to run the WordPress blog project"
rm -rf install.sh
