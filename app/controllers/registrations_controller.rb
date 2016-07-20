require 'net/http'

class RegistrationsController < Devise::RegistrationsController

  before_action :qrcode,  only: [:edit, :update]

  def qrcode
    session[:reauthenticate] = nil
    @session_id = rand(36**10).to_s(36)
    @ss_id = rand(36**10).to_s(36)
    Rails.cache.write("session.state.#{@session_id}", "initial")

    request_data = {action: "register",
                    ss_id: @ss_id,
                    name: "ShoCard Client Demo Site",
                    shocardid_er: Rails.configuration.shocard_id
                  }
    request = {data: request_data}
    response = HTTPClient.new.post("#{Rails.configuration.adaptorurl}/#{Rails.configuration.shocard_id}/qrcode",
                                   request.to_json,
                                   {"Content-Type" => "application/json"})

    response_data = JSON.parse(response.content)
    @qr_id = response_data["id"]
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
