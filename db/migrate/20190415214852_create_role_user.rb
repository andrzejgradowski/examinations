class CreateRoleUser < ActiveRecord::Migration[5.2]
  def change
    create_table :roles_users, id: false do |t|
      t.references :role, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps      
    end
    add_index :roles_users, [:role_id, :user_id],     unique: true
    add_index :roles_users, [:user_id, :role_id],     unique: true
  end
end
