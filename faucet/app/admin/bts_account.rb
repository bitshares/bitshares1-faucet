ActiveAdmin.register BtsAccount do

  actions :all, except: [:update, :destroy, :edit]

  index do
    selectable_column
    id_column
    column :user
    column :name
    column :key
    column :referrer
    column :created_at
    actions
  end

  filter :name
  filter :key
  filter :referrer
  filter :created_at

end
