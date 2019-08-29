class CreateProposals < ActiveRecord::Migration[5.2]
  def change
    create_table :proposals do |t|
      t.uuid :multi_app_identifier,         null: false, index: true
      t.integer :proposal_status_id,        null: false, index: true
      t.string :category,                   limit: 1, null: false, index: true
      #add_reference :orders, :creator, foreign_key: { to_table: :users }
      t.references :creator, foreign_key: { to_table: :users }
      # customer
      #t.boolean :human,                           null: false, default: true
      t.string :name,                       limit: 160, default: "",   null: false
      t.string :given_names,                limit: 50,  default: "",   null: false
      #t.string :nip, index: true,                 limit: 13, default: ""
      #t.string :regon, index: true,               limit: 9, default: ""
      t.string :pesel, index: true,         limit: 11, default: ""
      t.date :birth_date
      t.string :birth_place,                limit: 50, default: ""
      #t.string :fathers_name,                     limit: 50, default: ""
      #t.string :mothers_name,                     limit: 50, default: ""
      #t.string :family_name,                      limit: 50, default: ""
      #t.references :citizenship, index: true, foreign_key: true, default: 2
      t.string :phone,                      limit: 50, default: ""
      #t.string :fax,                              limit: 50, default: ""
      t.string :email,                      limit: 50, default: "",   null: false
      # customer_address
      #t.boolean :address_in_poland,         default: true, null: false
      t.string :address_city,               limit: 50, default: "",   null: false
      t.string :address_street,             limit: 50, default: "" 
      t.string :address_house,              limit: 10, default: ""
      t.string :address_number,             limit: 10, default: "" 
      t.string :address_postal_code,        limit: 10, default: ""
      #t.string :address_post_office,              limit: 50, default: ""
      #t.string :address_pobox,                    limit: 10, default: ""
      #t.integer "address_teryt_pna_code_id"
      #t.boolean :c_address_in_poland,       null: false
      t.string :c_address_city,             limit: 50, default: ""
      t.string :c_address_street,           limit: 50, default: "" 
      t.string :c_address_house,            limit: 10, default: ""
      t.string :c_address_number,           limit: 10, default: "" 
      t.string :c_address_postal_code,      limit: 10, default: ""
      #t.string :c_address_post_office,            limit: 50, default: ""
      #t.string :c_address_pobox,                  limit: 10, default: ""
      #t.integer  "c_address_teryt_pna_code_id"
      # Eeexam
      t.integer :esod_category
      #t.string   "examination_category",        limit: 1, default: "Z",   null: false
      t.integer :exam_id
      t.string :exam_fullname
      t.date :date_exam
      t.integer :division_id
      t.string :division_fullname
      t.integer :exam_fee_id
      t.decimal :exam_fee_price, precision: 8, scale: 2, default: 0.00
      #t.string   "examination_result",          limit: 1
      #t.integer  "customer_id"
      #t.string   "category",                    limit: 1
      #t.integer  "user_id"
      #t.integer  "certificate_id"
      #t.boolean  "supplementary",               default: false, null: false
      t.boolean :confirm_that_the_data_is_correct, default: false

      t.timestamps
    end
  end
end

  # def change
  #   add_reference :orders, :creator, foreign_key: { to_table: :users }
  # end
  # in model:
  # belongs_to :creator, class_name: 'User'