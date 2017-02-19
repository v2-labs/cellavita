# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

# Set our default provider for this Vagrantfile to 'vmware_fusion', this setting
# will match vmware_appcatalyst, vmware_fusion and vmware_desktop
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'vmware_fusion'

@script = <<SCRIPT
DOCUMENT_ROOT_ZEND="/var/www/cellavita"
apt-mark hold linux-image
apt-get update
apt-get install -y debconf-utils
apt-get install -y apache2 git curl php5-cli php5 php5-intl libapache2-mod-php5
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y mysql-server mysql-client php5-mysql
echo "
<VirtualHost *:80>
    ServerName cellavita-api.local
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
    ServerName cellavita.local
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
192.168.83.11   cellavita.local      cellavita.local
192.168.83.11   cellavita-api.local  cellavita-api.local
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
mysql -u root -proot < /var/www/cellavita/support-files/mysql-base-data.sql > \
                       /var/www/cellavita/support-files/mysql-base-data.log 2>&1
echo "** [Project] Visit http://cellavita.local in your browser to view the application **"
SCRIPT

node = {
  box: 'v2lab/trusty64',
  machine: 'cellavita',
  hostname: 'cellavita-devel',
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define node[:machine] do |node_config|
    node_config.vm.box = node[:box]
    node_config.vm.network 'private_network', ip: "192.168.83.11"
    node_config.vm.hostname = node[:hostname]
    node_config.vm.synced_folder '.', '/var/www/cellavita'
    node_config.vm.provision 'shell', inline: @script

    # Configure our boxes with 1 CPU and 1GB of RAM
    node_config.vm.provider 'vmware' do |v|
      v.cpus = '1'
      v.memory = '1024'
    end
  end
end
