class ChangeCsuConfirmedAtFormatInUser < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :csu_confirmed_at, :datetime
  end

  def down
    change_column :users, :csu_confirmed_at, :date
  end
end
