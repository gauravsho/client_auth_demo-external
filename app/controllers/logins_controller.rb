require 'net/http'

class LoginsController < Devise::SessionsController

  def new
    @session_id = rand(36**10).to_s(36)
    @ss_id = rand(36**10).to_s(36)
    Rails.cache.write("session.state.#{@session_id}", "initial")

    request_data = {action: "login",
                    ss_id: @ss_id,
                    data: {name: "ShoCard Client Demo Site",
                           shocardid_be: Rails.configuration.shocardid_be}}

    begin
      response = HTTPClient.new.post("#{Rails.configuration.adaptorurl}/#{Rails.configuration.shocardid_be}/qrcode",
                                     request_data.to_json,
                                     {"Content-Type" => "application/json"})
      response_data = JSON.parse(response.content)
      @qr_id = response_data["id"]
      Rails.cache.write("ss.session.#{@ss_id}", @session_id)
    rescue
    end

    super
  end

  def new_pn
    @ss_id = rand(36**10).to_s(36)
    @username = params[:username]
    @session_id = params[:session_id]
    @user = User.find_by_email(@username)
    shocardid_ee = @user.shocardid
    shocardid_be = Rails.configuration.shocardid_be

    request_data = {"shocardid_ee" => shocardid_ee,
                    "shocardid_be" => shocardid_be,
                    "ss_id" => @ss_id,
                    "action" => "login",
                    "name" => "ShoCard Client Demo Site"}

    HTTPClient.new.post("#{Rails.configuration.adaptorurl}/#{Rails.configuration.shocardid_be}/share",
                         request_data.to_json,
                         {"Content-Type" => "application/json"})

    Rails.cache.write("ss.session.#{@ss_id}", @session_id)
    render :nothing => true, :status => 200, :content_type => 'application/json'
  end

  def ok
    redirect_to root_url, notice: "Successfully logged in with your ShoCard"
  end


end