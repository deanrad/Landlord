class CreateOwners < ActiveRecord::Migration
  def self.up
    create_table :owners do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
    create_table :owners_units, :id=>false do |t|
      t.integer :owner_id
      t.integer :unit_id
    end
  end

  def self.down
    drop_table :owners_units
    drop_table :owners
  end
end
