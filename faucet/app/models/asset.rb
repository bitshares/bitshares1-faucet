class Asset < ActiveRecord::Base
  has_many :referral_codes

  def self.sync_with_blockchain
    counter = 0
    data = BitShares::API::Blockchain.list_assets()
    data.each do |a|
      next if Asset.exists?(assetid: a['id'])
      Asset.create(assetid: a['id'], symbol: a['symbol'], name: a['name'], description: a['description'][0..240], precision: a['precision'])
      counter += 1
    end
    puts "Added assets: #{counter}"
  end

end
