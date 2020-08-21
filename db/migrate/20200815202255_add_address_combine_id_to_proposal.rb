class AddAddressCombineIdToProposal < ActiveRecord::Migration[5.2]
  def change
    add_column :proposals, :address_combine_id, :string, limit: 26, default: "", null: false
  end
end
