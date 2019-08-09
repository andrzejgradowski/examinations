class CreateIndividualDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :individual_devices do |t|
      t.string :number, index: true,            default: ""
      t.date :date_of_issue, index: true
      t.date :valid_to, index: true
      t.string :call_sign, index: true,         default: ""
      t.string :category, index: true,          default: ""
      t.integer :transmitter_power, index: true
      t.string :name_type_station, index: true, default: ""
      t.string :emission, index: true,          default: ""
      t.string :input_frequency, index: true,   default: ""
      t.string :output_frequency, index: true,  default: ""
      t.string :station_location, index: true,  default: ""

      t.timestamps null: false
    end
  end
end
