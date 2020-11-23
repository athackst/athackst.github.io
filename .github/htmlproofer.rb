require 'html-proofer'

# set -eu

# bundle exec htmlproofer \
#   _site \
#   --file-ignore /amp/,/.git/ \
#   --check-favicon \
#   --check-html \
#   --check-opengraph

# becomes

options = { 
  assume_extension: false,
  check_favicon: false,
  check_opengraph: false,
  check_html: true,
  internal_domains: ["https://allisonthackston.com", "https://www.allisonthackston.com"],
  url_swap: { %r{https?\:\/\/(localhost\:4000|www.allisonthackston\.com)} => ''},
  parallel: { in_processes: 3 },
  typhoeus: {
    ssl_verifypeer: false,
    ssl_verifyhost: 0 }
}

HTMLProofer.check_directory("./_site", options).run
