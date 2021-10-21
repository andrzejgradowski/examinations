class AddExamOnlineToProposal < ActiveRecord::Migration[5.2]
  def change
    add_column :proposals, :exam_online, :boolean, null: false, default: false
  end
end
