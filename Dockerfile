FROM foodcoops/foodsoft:latest

USER root

COPY plugins plugins

# enable plugins
RUN echo "" >>Gemfile && \
    echo "# plugins added in Vokomokum image" >>Gemfile && \
    echo "gem 'foodsoft_shop', path: 'plugins/shop'" >>Gemfile && \
    echo "gem 'foodsoft_vokomokum', path: 'plugins/vokomokum'" >>Gemfile && \
    echo "gem 'foodsoft_current_orders', path: 'plugins/current_orders'" >>Gemfile

# install Ruby dependencies
RUN echo 'gem: --no-document' >> ~/.gemrc && \
    bundle config build.nokogiri "--use-system-libraries" && \
    bundle config --delete frozen && \
    bundle install --without development test -j 4 && \
    rm -Rf ~/.gemrc ~/.bundle

# Then add migrations and update database schema
RUN export DATABASE_URL=mysql2://localhost/temp && \
    export SECRET_KEY_BASE=thisisnotimportantnow && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y mariadb-server && \
    /etc/init.d/mysql start && \
    mariadb -e "CREATE DATABASE temp" && \
    cp config/app_config.yml.SAMPLE config/app_config.yml && \
    cp config/database.yml.MySQL_SAMPLE config/database.yml && \
    bundle exec rake db:setup foodsoft_vokomokum_engine:install:migrations && \
    bundle exec rake db:migrate assets:precompile && \
    rm -Rf config/app_config.yml tmp/* && \
    /etc/init.d/mysql stop && \
    rm -Rf /run/mysqld /tmp/* /var/tmp/* /var/lib/mysql /var/log/mysql* && \
    apt-get purge -y --auto-remove mariadb-server && \
    rm -Rf /var/lib/apt/lists/* /var/cache/apt/*

# Run app as unprivileged user
USER nobody
