class AddShocardIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :shocardid, :string
  end
end
