ActiveAdmin.register UserAction do

  actions :all, except: [:update, :destroy, :edit]

  index do
    selectable_column
    id_column
    column :uid
    column :action
    column :value
    column :refurl
    column :channel
    column :referrer
    column :campaign
    column :adgroupid
    column :adid
    column :keywordid
    column :created_at
    actions
  end

  filter :uid
  filter :action
  filter :value
  filter :refurl
  filter :channel
  filter :referrer
  filter :campaign
  filter :created_at

end
