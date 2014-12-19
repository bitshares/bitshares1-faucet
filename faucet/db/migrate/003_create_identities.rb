class CreateIdentities < ActiveRecord::Migration
  def change

    create_table :identities do |t|
      t.references :user, index: true
      t.string :provider
      t.string :uid
      t.string :email
      t.timestamps
    end

    add_index :identities, [:provider, :uid], unique: true

  end
end
