# lib/tasks/cronjobs.rake

namespace :cronjobs do

  desc "Sending exam reminders"
  task proposal_send_reminders: :environment do
    Proposal.send_reminders
  end

  desc "Clean unsaved proposals"
  task proposal_clean_unsaved: :environment do
    Proposal.clean_unsaved
  end

end