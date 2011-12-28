class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   "provider",    :null => false
      t.integer  "uid",         :null => false
      t.string   "screen_name", :null => false
      t.string   "name",        :null => false
      t.text     "token",       :null => false
      t.text     "secret",      :null => false
      t.timestamps
    end
  end
end
