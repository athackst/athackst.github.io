bundle exec htmlproofer \
    --internal_domains https://allisonthackston.com \
    --url-swap "https?\:\/\/(localhost\:4000|www.allisonthackston\.com):" \
    --http-status-ignore 302 \
    ./_site
