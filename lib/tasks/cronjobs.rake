# lib/tasks/cronjobs.rake
require 'pwid'

namespace :cronjobs do
  desc "Sending exam reminders"
  task proposal_reminders: :environment do
    Proposal.send_reminders
  end

end