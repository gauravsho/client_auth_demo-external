require 'net/http'

class LoginsController < Devise::SessionsController

  def new
    @session_id = rand(36**10).to_s(36)
    @ss_id = rand(36**10).to_s(36)
    Rails.cache.write("session.state.#{@session_id}", "initial")

    request_data = {
      action: "login",
      ss_id: @ss_id,
      name: "ShoCard Client Demo Site",
      shocardid_er: Rails.configuration.shocard_id}

      request = {data: request_data}
      puts "qrcode #{request}"
    begin
      response = HTTPClient.new.post("#{Rails.configuration.adaptorurl}/#{Rails.configuration.shocard_id}/qrcode",
                                     request.to_json,
                                     {"Content-Type" => "application/json"})
      response_data = JSON.parse(response.content)
      puts "response_data #{response_data}"
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
    shocardid_er = Rails.configuration.shocard_id

    request_data = {
      action: "login",
      ss_id: @ss_id,
      name: "ShoCard Client Demo Site",
      shocardid_ee: shocardid_ee,
      shocardid_er: shocardid_er
    }

    share_data = {
      shocardid_to: @user.shocardid,
      shocardid_from: Rails.configuration.shocard_id,
      data: request_data
    }


    HTTPClient.new.post("#{Rails.configuration.adaptorurl}/#{Rails.configuration.shocard_id}/share",
                         share_data.to_json,
                         {"Content-Type" => "application/json"})

    Rails.cache.write("ss.session.#{@ss_id}", @session_id)
    render :nothing => true, :status => 200, :content_type => 'application/json'
  end

  def ok
    redirect_to root_url, notice: "Successfully logged in with your ShoCard"
  end


end
