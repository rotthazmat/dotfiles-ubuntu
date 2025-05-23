alias bash_edit='code ~/.bashrc'
alias bash_update='source ~/.bashrc'
alias bash_aliases='code ~/.bash_aliases'
alias cd_home='cd ~'
alias cd_local='cd /var/www/html'
alias cd_localhost='cd /var/www/html'
alias explorer='explorer.exe .'
alias perm_full='sudo chmod -R 777 .'
alias apache_settings='sudo vim /etc/apache2/sites-available/000-default.conf'
alias apache_status='sudo service apache2 status'
alias apache_errors='code /var/log/apache2/error.log'
alias apache_errors_perm='sudo chmod 777 /var/log/apache2/error.log'
alias apache_errors_clean='sudo echo > /var/log/apache2/error.log'
alias apache_start='sudo service apache2 start'
alias apache_restart='sudo service apache2 restart'
alias apache_stop='sudo service apache2 stop'
alias nginx_settings='sudo vim /etc/nginx/sites-available/default'
alias nginx_status='sudo service nginx status'
alias nginx_start='sudo service nginx start'
alias nginx_restart='sudo service nginx restart'
alias nginx_stop='sudo service nginx stop'
alias php_settings='code /etc/php/8.3/fpm/pool.d/www.conf'
alias php_restart='sudo service php8.3-fpm restart'
alias mysql_version='mysql -V'
alias mysql_status='sudo service mysql status'
alias mysql_start='sudo service mysql start'
alias mysql_restart='sudo service mysql restart'
alias mysql_stop='sudo service mysql stop'
alias mysql_enable='sudo systemctl enable mysql'
alias postgresql_version='psql -V'
alias postgresql_status='sudo service postgresql status'
alias postgresql_start='sudo service postgresql start'
alias postgresql_restart='sudo service postgresql restart'
alias postgresql_stop='sudo service postgresql stop'
alias postgresql_enable='sudo systemctl enable postgresql'
alias mongodb_version='mongod --version'
alias mongodb_status='sudo systemctl status mongod'
alias mongodb_start='sudo systemctl start mongod'
alias mongodb_restart='sudo systemctl restart mongod'
alias mongodb_stop='sudo systemctl stop mongod'
alias mongodb_enable='sudo systemctl enable mongod'
alias remove_zone_identifiers='find . -name "*:Zone.Identifier" -type f -delete'
alias system_details='fastfetch'
alias system_info='fastfetch'
alias spigot_start='java -Xmx6144M -Xms6144M -jar paper.jar nogui PAUSE'
alias gradle_jar="gradle jar"
