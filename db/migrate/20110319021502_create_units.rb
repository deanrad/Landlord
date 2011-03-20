class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table :units do |t|
      t.string :title

      t.integer :floor
      t.string  :direction, :size => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :units
  end
end
