ActiveAdmin.register Identity do

  actions :all, except: [:update, :destroy, :edit]

  index do
    selectable_column
    id_column
    column :user
    column :provider
    column :uid
    column :email
    column :created_at
    actions
  end

  filter :provider
  filter :email
  filter :created_at

end
