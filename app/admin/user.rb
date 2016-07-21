ActiveAdmin.register User, as: "Sales Person" do

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
  permit_params :email, :first_name, :last_name, :address1, :address2, :city, :state, :country, :user_type, :verified

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
    column :country
    actions
  end

  filter :user_type
  filter :email
  filter :first_name
  filter :last_name
  filter :address1
  filter :address2
  filter :city
  filter :state
  filter :country

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :address1
      f.input :address2
      f.input :city
      f.input :state
      f.input :country, as: :country, priority_countries: ["US", "CA", "GB", "FR"]
      f.input :user_type, :as => :hidden, :input_html => { :value => "seller" }
      f.input :verified, :as => :hidden, :input_html => { :value => true }
    end
    f.actions
  end
end
