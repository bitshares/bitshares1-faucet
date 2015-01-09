class CreateWidgetsAndUserActions < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.references :user, index: true
      t.string :allowed_domains
      t.timestamps
    end

    create_table :user_actions do |t|
      t.references :widget, index: true
      t.string :uid
      t.string :action, limit: 16
      t.string :value
      t.string :ip, limit: 48
      t.string :ua
      t.string :city
      t.string :state
      t.string :country
      t.string :refurl
      t.string :channel, limit: 64
      t.string :referrer, limit: 64
      t.string :campaign, limit: 64
      t.integer :adgroupid
      t.integer :adid
      t.integer :keywordid
      t.timestamp :created_at
    end

    add_index :user_actions, [:action], unique: false
    add_index :user_actions, [:uid], unique: false
    add_index :user_actions, [:channel], unique: false
    add_index :user_actions, [:referrer], unique: false
    add_index :user_actions, [:campaign], unique: false

    add_column :users, :uid, :string, limit: 32
    add_index :users, [:uid], unique: false

  end
end
