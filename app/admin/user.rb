ActiveAdmin.register User do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end
  permit_params :email, :first_name, :last_name, :address1, :address2, :city, :state, :country, :postalcode, :phone_number

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :address1
    column :address2
    column :city
    column :state
    column :postalcode
    column :phone_number
    column :device_token
    column :phone_code
    column :verified
    column :photo_url
    column :sign_in_count
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    column :social_type
    column :token
    actions
  end

  filter :email
  filter :first_name
  filter :last_name
  filter :address1
  filter :address2
  filter :city
  filter :state
  filter :postalcode
  filter :phone_number
  filter :verified
  filter :social_type

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :phone_number
      f.input :first_name
      f.input :last_name
    end
    f.actions
  end
end
