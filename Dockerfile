FROM niku/debian
MAINTAINER niku

RUN apt-get update && \
    apt-get -y install build-essential ruby2.1-dev cmake pkg-config git apache2 libapache2-mod-passenger && \
    echo "<VirtualHost *:80>\n    DocumentRoot /var/www/nwiki/public\n    <Directory /var/www/nwiki/public>\n        Allow from all\n        Options -MultiViews\n    </Directory>\n</VirtualHost>" > /etc/apache2/sites-available/nwiki.conf && \
    a2dissite 000-default && \
    a2ensite nwiki && \
    git clone https://github.com/niku/nwiki.git /var/www/nwiki && \
    cd /var/www/nwiki && gem install bundler && bundle install

EXPOSE 80 443
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
