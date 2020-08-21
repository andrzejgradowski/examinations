class RemoveAddressIdFromProposal < ActiveRecord::Migration[5.2]
  def change
    remove_column :proposals, :address_id, :int
  end
end
