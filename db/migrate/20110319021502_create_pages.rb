class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :slug
      t.string :title

      t.integer :floor
      t.string  :direction, :size => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
