class CreateIndividuals < ActiveRecord::Migration[5.2]
  def change
    create_table :individuals do |t|
      t.string :number, index: true,            default: ""
      t.date :date_of_issue, index: true
      t.date :valid_to, index: true
      t.string :call_sign, index: true,         default: ""
      t.string :category, index: true,          default: ""
      t.integer :transmitter_power, index: true
      t.string :station_location, index: true,  default: ""

      t.timestamps null: false
    end
  end
end
