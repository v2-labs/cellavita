# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

# Set our default provider for this Vagrantfile to 'vmware_appcatalyst'
#ENV['VAGRANT_DEFAULT_PROVIDER'] = 'vmware_appcatalyst'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'vmware_fusion'

@script = <<SCRIPT
DOCUMENT_ROOT_ZEND="/var/www/cellavita"
apt-get update
apt-get install -y debconf-utils
apt-get install -y apache2 git curl php5-cli php5 php5-intl libapache2-mod-php5
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y mysql-server mysql-client php5-mysql
echo "
<VirtualHost *:80>
    ServerName cellavita-api.test
    DocumentRoot $DOCUMENT_ROOT_ZEND/api/public
    SetEnv APPLICATION_ENV 'development'
    <Directory $DOCUMENT_ROOT_ZEND/api/public>
        DirectoryIndex index.php
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/cellavita_api.conf
echo "
<VirtualHost *:80>
    ServerName cellavita.test
    DocumentRoot $DOCUMENT_ROOT_ZEND/web/public
    SetEnv APPLICATION_ENV 'development'
    <Directory $DOCUMENT_ROOT_ZEND/web/public>
        DirectoryIndex index.php
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/cellavita_web.conf
echo "
192.168.83.11   cellavita.test      cellavita.test
192.168.83.11   cellavita-api.test  cellavita-api.test
" >> /etc/hosts
sed -i "s/^bind-address/#bind-address/g" /etc/mysql/my.cnf
a2enmod rewrite
a2dissite 000-default
a2ensite cellavita_api
a2ensite cellavita_web
service apache2 restart
mysql -u root -proot --execute "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' with GRANT OPTION; FLUSH PRIVILEGES;"
service mysql restart
cd /var/www/cellavita
for site in api web; do
    pushd ${site} > /dev/null
    if [[ ! -f composer.phar ]]; then
        curl -Ss https://getcomposer.org/installer | php
    else
        php composer.phar self-update
    fi
    php composer.phar install --no-progress
    popd > /dev/null
done
echo "** [Project] Visit http://cellavita in your browser to view the application **"
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'v2lab/trusty64'
  config.vm.network 'private_network', ip: "192.168.83.11"
  config.vm.hostname = 'cellavita-devel'
  config.vm.synced_folder '.', '/var/www/cellavita'
  config.vm.provision 'shell', inline: @script

  # Configure our boxes with 1 CPU and 1GB of RAM
  config.vm.provider 'vmware_fusion' do |v|
    v.cpus = '1'
    v.memory = '1024'
  end
end
