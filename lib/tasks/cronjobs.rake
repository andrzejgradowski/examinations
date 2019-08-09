# lib/tasks/cronjobs.rake
require 'pwid'

namespace :cronjobs do
  desc "Synchronize data with system PWID-AMATOR"
  task pwid_sync: :environment do
    PwidModule::pwid_whenever
  end

end