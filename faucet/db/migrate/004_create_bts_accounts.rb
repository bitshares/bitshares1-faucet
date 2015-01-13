class CreateBtsAccounts < ActiveRecord::Migration
  def change

    create_table :bts_accounts do |t|
      t.references :user, index: true
      t.string :name
      t.string :key
      t.string :referrer
      t.string :ogid
      t.timestamps
    end

    add_index :bts_accounts, [:name], unique: true
    add_index :bts_accounts, [:key], unique: true
    add_index :bts_accounts, [:ogid], unique: true

  end
end
