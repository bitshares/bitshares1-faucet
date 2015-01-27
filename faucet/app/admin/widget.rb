ActiveAdmin.register Widget do
  actions :all, except: [:destroy]
  permit_params :allowed_domains

  index do
    selectable_column
    id_column
    column :user
    column :allowed_domains
    column :created_at
    actions
  end

  filter :user
  filter :allowed_domains
  filter :created_at

  form do |f|
    f.inputs "Widget Details" do
      f.input :allowed_domains
    end
    f.actions
  end


end
