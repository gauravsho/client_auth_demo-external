require 'net/http'
require 'utils'

class LoginsController < Devise::SessionsController

  def new
    @session_id = rand(36**10).to_s(36)
    @ss_id = rand(36**10).to_s(36)
    Rails.cache.write("session.state.#{@session_id}", "initial")
    Rails.cache.write("session.action.#{@session_id}", "login")

    request_data = {
      message: "Please provide your ShoCard ID associated with this site to login",
      ss_id: @ss_id,
      name: "ShoCard Client Demo Site",
      shocardid: Rails.configuration.shocard_id,
      action: "request_share"
    }

      request = { shocard: request_data }
      puts "qrcode #{request}"
    begin
      @qr_id = Utils::storeDataInShoStore(request)
      puts "ShoStore URL: #{@qr_id}"
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
    shocardid = @user.shocardid
    Rails.cache.write("ss.session.#{@ss_id}", @session_id)
    Rails.cache.write("session.action.#{@session_id}", "login")

    share_message = "The ShoCard Client Demo Site has requested your ShoCard Id to login to the site."
    p share_message
    share_request = { ss_id: @ss_id, recipient_shocardid: shocardid, message: share_message, requested_keys: [ ]}

    response = HTTPClient.new.put("#{Rails.configuration.adaptorurl}/#{Rails.configuration.shocard_id}/request_share/#{@ss_id}",
                         share_request.to_json,
                         {"Content-Type" => "application/json"})

    p response.code
    p response.body

    render :nothing => true, :status => 200, :content_type => 'application/json'
  end

  def ok
    redirect_to root_url, notice: "Successfully logged in with your ShoCard"
  end


end
