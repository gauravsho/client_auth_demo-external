require 'active_support'

class SessionsController < ApplicationController

  def show
    session_id = params[:id]
    state = Rails.cache.read("session.state.#{session_id}")

    #for login only
    user = User.find(Integer(state)) rescue nil
    if user
      sign_in :user, user
      Rails.cache.write("session.state.#{session_id}", "ok")
    end

    render json: {state: state}.to_json, :content_type => 'application/json'
  end

  def create_certification(certification_record)
    puts "create_certification"
    request_data = {id: certification_record[:id], data: certification_record}
    response = HTTPClient.new.put("#{Rails.configuration.adaptorurl}/#{Rails.configuration.shocard_id}/certifications",
                           request_data.to_json,
                           {"Content-Type" => "application/json"})
    response_data = JSON.parse(response.content)
  end

  def share(toshocardid, data)

    request_data = {
      shocardid_to: toshocardid,
      shocardid_from: "#{Rails.configuration.shocard_id}",
      data: data
    }

    #request_data = data.merge(request_data)

    response = HTTPClient.new.post("#{Rails.configuration.adaptorurl}/#{Rails.configuration.shocard_id}/share",
                           request_data.to_json,
                           {"Content-Type" => "application/json"})
    #response_data = JSON.parse(response.content)
  end
  #a callback that Adapter calls on successful registration
  def update_registrations
    #begin
    approval = params[:approval]
    rts = params[:rts]
    share_request = params[:req]
    resp_share_data = params[:resp]

    shocardid_er = share_request[:shocardid_er]
    name_er = share_request[:name]
    ss_id = share_request[:ss_id]

    type = resp_share_data[:type]
    if type == "userrecord"
      user_data = resp_share_data[:data]
      shocardid_ee = user_data[:shocardid]
      name_ee = user_data[:name]
      seal_id = user_data[:seal_id]
      email = name_ee.downcase.gsub(' ', '_') + "@example.com"
      session_id = Rails.cache.read("ss.session.#{ss_id}")
      Rails.cache.write("session.state.#{session_id}", shocardid_ee)
    else
      puts "unknow type #{type}"
    end
    render json: {}.to_json, :content_type => 'application/json', :status => status || 200
  end

  def update_logins
    begin
      if params[:approval].present?
        ss_id = params[:ssid]
        shocardid = params[:shocardid]
        user = User.find_by_shocardid(shocardid)
        session_id = Rails.cache.read("ss.session.#{ss_id}")

        if user
          Rails.cache.write("session.state.#{session_id}", user.id)
        else
          status = 404
        end
      else
        #no action on the site if user has rejected the login request
      end
    rescue
      status = 422 #something went wrong
    end

    render json: {}.to_json, :content_type => 'application/json', :status => status || 200
  end

  #a callback that Adapter calls on registration attempt
  def verify

    puts "verify #{params}"
    approval = params[:approval]
    rts = params[:rts]
    share_request = params[:req]
    resp_share_data = params[:resp]

    shocardid_er = share_request[:shocardid_er]
    name_er = share_request[:name]
    ss_id = share_request[:ss_id]

    type = resp_share_data[:type]
    if type == "userrecord"
      user_data = resp_share_data[:data]
      shocardid_ee = user_data[:shocardid]
      name_ee = user_data[:name]
      seal_id = user_data[:seal_id]
      email = name_ee.downcase.gsub(' ', '_') + "@example.com"
    else
      puts "unknow type #{type}"
    end

    fields_verified = ['pp.Last Name', 'pp.First Name', 'dl.Last Name', 'dl.First Name', 'ps.Last Name', 'ps.First Name']
    message = {state: :accept, approval: approval, shocardid_ee: shocardid_ee, name_ee: name_ee, info: rts, fields: fields_verified}

    render json: message.to_json, :content_type => 'application/json', :status => status || 200
  end

  #a callback that Adapter calls on forwarding a certification
  def update_certifications
    begin
    #   if params[:data].present?
    #     #shocardid = params[:shocardid]
    #   else
    #     #no action on the site if user has rejected the register request
    #   end
    rescue
      status = 422 #something went wrong
    end

    render json: {}.to_json, :content_type => 'application/json', :status => status || 200
  end
end
