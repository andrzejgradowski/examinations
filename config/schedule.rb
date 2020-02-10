# Learn more: http://github.com/javan/whenever
#require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

#env :PATH, ENV['PATH']

#set :environment_variable, :production
set :output, "#{Rails.root}/log/cron_log.log"

every '0 10 * * *' do
  runner "Proposal.send_reminder"
end
