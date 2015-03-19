#!/bin/bash

# needed for ssh-agent auth under cron on OS X
declare -x SSH_AUTH_SOCK=$( find /tmp/com.apple.launchd.*/Listeners -user $(whoami) -type s | head -1 )

wget http://atlantides.org/downloads/pleiades/dumps/pleiades-places-latest.csv.gz http://atlantides.org/downloads/pleiades/dumps/pleiades-locations-latest.csv.gz http://atlantides.org/downloads/pleiades/dumps/pleiades-names-latest.csv.gz
gunzip *.csv.gz
git checkout gh-pages
git pull
git merge  -s recursive -Xtheirs --no-edit master
bundle install
bundle exec ./pleiades-static.rb pleiades-places-latest.csv pleiades-names-latest.csv pleiades-locations-latest.csv
git add places
git commit -m "$(date '+%Y-%m-%d') pleiades-static update"
git push
rm -fv *.csv *.csv.gz
git checkout master
