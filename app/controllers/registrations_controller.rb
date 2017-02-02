require 'net/http'
require 'utils'

class RegistrationsController < Devise::RegistrationsController

  before_action :qrcode,  only: [:edit, :update]

  def qrcode
    session[:reauthenticate] = nil
    @session_id = rand(36**10).to_s(36)
    @ss_id = rand(36**10).to_s(36)
    Rails.cache.write("session.state.#{@session_id}", "initial")
    Rails.cache.write("session.action.#{@session_id}", "register")

    request_data = {message: "Do you agree to provide your ShoCard ID to register with the site",
                    ss_id: @ss_id,
                    name: "ShoCard Client Demo Site",
                    requested_keys: [ ],
                    shocardid: Rails.configuration.shocard_id,
                    action: "request_share"
                  }

    request = { shocard: request_data }
    @qr_id = Utils::storeDataInShoStore(request)
    p "ShoStore URL: #{@qr_id}"
    Rails.cache.write("ss.session.#{@ss_id}", @session_id)
    Rails.cache.write("ss.user.#{@ss_id}", current_user.id)
  end

  def ok
    redirect_to root_url, notice: "Successfully registered your ShoCard"
  end

  private

  def sign_up_params
    params.require(:user).permit(:shocardid, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:shocardid, :email, :password, :password_confirmation, :current_password)
  end

end
