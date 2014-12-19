class CreateReferralCodesAndAssets < ActiveRecord::Migration
  def change
    create_table(:assets) do |t|
      t.integer :assetid
      t.string :symbol
      t.string :name
      t.string :description
      t.integer :precision
      t.timestamps
    end

    add_index :assets, :assetid, unique: true
    add_index :assets, :symbol, unique: true

    create_table(:referral_codes) do |t|
      t.string :code
      t.string :account_name
      t.integer :ref_code_id
      t.integer :asset_id
      t.integer :amount, :limit => 8
      t.datetime :expires_at
      t.boolean :funded
      t.string :prerequisites
      t.datetime :redeemed_at
      t.timestamps
    end

    add_index :referral_codes, :code, unique: true
    add_index :referral_codes, :ref_code_id, unique: false
    add_index :referral_codes, :asset_id, unique: false
  end
end
