# Learn more: http://github.com/javan/whenever
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

env :PATH, ENV['PATH']
set :bundle_command, "/home/deploy/.rbenv/shims/bundle exec"


set :environment, :production
set :output, "#{Rails.root}/log/cron_log.log"

# every '00 10 * * *' do
#   runner "Proposal.send_reminders"
# end

every '00 6 * * *' do
  rake "cronjobs:proposal_clean_unsaved"
end

every '00 10 * * *' do
  rake "cronjobs:proposal_send_reminders"
end
