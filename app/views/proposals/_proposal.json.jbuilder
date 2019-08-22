json.extract! proposal, :id, :uuid, :proposal_status_id, :name, :given_names, :creator_id, :created_at, :updated_at
json.url proposal_url(proposal, format: :json)
