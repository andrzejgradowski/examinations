#env :GEM_PATH, ENV['GEM_PATH']

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/../lib/pwid")

env :PATH, ENV['PATH']
set :bundle_command, "/home/deploy/.rbenv/shims/bundle exec"


set :environment, :production
set :output, "#{Rails.root}/log/cron_log.log"


every '45 4 * * 1-5' do
  rake "cronjobs:pwid_sync"
end
