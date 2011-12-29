class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.integer :uid, :null => false
      t.datetime :sample_start
      t.datetime :sample_end

      t.timestamps
    end
    add_index :targets, :uid
  end
end
