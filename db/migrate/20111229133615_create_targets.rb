class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.integer :uid, :null => false
      t.datetime :sample_end
      t.text    :samples

      t.timestamps
    end
    add_index :targets, :uid
  end
end
