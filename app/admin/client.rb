ActiveAdmin.register User, as: "Client" do
  permit_params :email, :password, :password_confirmation
  controller do
    def scoped_collection
      super.clients
    end
  end
  index do
    selectable_column
    id_column
    column :email
    column "Password", :password_as_asteric
    actions
  end

  filter :email

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
