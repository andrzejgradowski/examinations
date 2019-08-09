class CreateClubs < ActiveRecord::Migration[5.2]
  def change
    create_table :clubs do |t|
      t.string :number, index: true,            default: ""
      t.date :date_of_issue, index: true
      t.date :valid_to, index: true
      t.string :call_sign, index: true,         default: ""
      t.string :category, index: true,          default: ""
      t.integer :transmitter_power, index: true
      t.string :enduser_name, index: true,      default: ""
      t.string :enduser_city, index: true,      default: ""
      t.string :enduser_street, index: true,    default: ""
      t.string :enduser_house, index: true,     default: ""
      t.string :enduser_number, index: true,    default: ""
      t.string :applicant_name, index: true,    default: ""
      t.string :applicant_city, index: true,    default: ""
      t.string :applicant_street, index: true,  default: ""
      t.string :applicant_house, index: true,   default: ""
      t.string :applicant_number, index: true,  default: ""
      t.string :station_city, index: true,      default: ""
      t.string :station_street, index: true,    default: ""
      t.string :station_house, index: true,     default: ""
      t.string :station_number, index: true,    default: ""

      t.float :lat, index: true
      t.float :lng, index: true

      t.timestamps null: false
    end
  end
end

