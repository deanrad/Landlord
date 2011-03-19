class CreateFloors < ActiveRecord::Migration
  def self.up
    create_table :floors do |t|
      t.integer :number

      t.timestamps
    end
  end

  def self.down
    drop_table :floors
  end
end
