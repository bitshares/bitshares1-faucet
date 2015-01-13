class CreateDvsAccounts < ActiveRecord::Migration
  def change

    create_table :dvs_accounts do |t|
      t.references :user, index: true
      t.string :name
      t.string :key
      t.string :referrer
      t.string :ogid
      t.timestamps
    end

    add_index :dvs_accounts, [:name], unique: true
    add_index :dvs_accounts, [:key], unique: true
    add_index :dvs_accounts, [:ogid], unique: true

  end
end
