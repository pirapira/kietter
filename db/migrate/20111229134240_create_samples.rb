class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.integer :target_id
      t.datetime :period
      t.boolean :presence

      t.timestamps
    end
  end
end
