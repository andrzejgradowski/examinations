class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :wso2is_userid
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :user_name
      t.date :birth_date
      t.string :birth_city
      t.string :pesel
      t.string :passport
      t.string :phone
      t.date :csu_confirmed_at
      t.string :csu_confirmed_by
      ## SAML
      t.string :session_index

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps
    end

    add_index :users, :email,                unique: true
  end
end
