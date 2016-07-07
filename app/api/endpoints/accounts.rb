module Endpoints
  class Accounts < Grape::API

    resource :accounts do

      # Accounts API test
      # /api/v1/accounts/ping
      # results  'gwangming'
      get :ping do
        { :ping => 'gwangming' }
      end

      # Verify phone code
      # POST: /api/v1/accounts/verify
      #   Parameters accepted
      #     phone_number String *
      #     phone_code String *
      #   Results
      #     {status: 1, data: {client data}}
      post :verify do
        user = User.where(phone_number: params[:phone_number]).first
        if user.present?
          if user.phone_code == params[:phone_code]
            user.generate_token
            user.verified = true

            if user.save
              return {status: 1,  data: user.verified}
            else
              return {status: 0, data: user.errors.messages}
            end
          else
            return {status: 0, data: "Sorry for inconvenience, we are not able to verify this number, please try again."}
          end
        else
          return {status: 0, data: "Your phone number doesn't exist"}
        end
      end

      # Resend phone code
      # POST: /api/v1/accounts/resend_phone_code
      #   Parameters accepted
      #     phone_number String *
      #   Results
      #     {status: 1, data: Message}
      post :resend_phone_code do
        user = User.where(phone_number: params[:phone_number]).first
        if user.present?
          if user.update(phone_code:User.digital_code, verified: false)
            user.reminder()
            return {status: 1,  data: "Resent phone code"}
          else
            return {status: 0, data: user.errors.messages}
          end
        else
          return {status: 0, data: "Your phone number doesn't exist"}
        end
      end

      # Setup user info
      # POST: /api/v1/accounts/setup
      #   Parameters accepted
      #     first_name String
      #     last_name String
      #     address1 String
      #     address2 String
      #     city  String
      #     state String
      #     country String
      #     postalcode String
      #     photo File data
      #   Results
      #     {status: 1, data: {client data}}
      post :setup do
        user = User.find_by_token params[:token]
        if user.present?
            user.first_name = params[:first_name]
            user.last_name  = params[:last_name]
            user.address1   = params[:address1]
            user.address2   = params[:address2]
            user.city       = params[:city]
            user.state      = params[:state]
            user.country    = params[:country]
            user.postalcode = params[:postalcode]
            user.photo      = params[:photo]
          if user.save
            return {status: 1,  data: user.info_by_json}
          else
            return {status: 0, data: user.errors.messages}
          end
        else
          return {status: 0, data: "Wrong token"}
        end
      end


      # Forgot Password
      # GET: /api/v1/accounts/forgot_password
      # parameters:
      #   email:      String *required
      # results:
      #   return success message
      get :forgot_password do
        user = User.where(email:params[:email]).first
        if user.present?
          user.send_reset_password_instructions
          {status: 1, data: 'Email was sent successfully'}
        else
          {status: 0, data: 'Cannot find your email'}
        end
      end

    end
  end
end
