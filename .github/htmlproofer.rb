#!/usr/local/bin/ruby
require 'html-proofer'

options = {
  parallel: { in_processes: 3 },
  typhoeus: {
    ssl_verifypeer: false,
    ssl_verifyhost: 0,
    timeout: 120,
    connecttimeout: 30
  },
  ignore_urls: ['https://www.linkedin.com/in/allisonthackston']
}

HTMLProofer.check_directory('./_site', options).run
