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

  #a callback that Adapter calls on successful registration
  def update_registrations
    begin
      if params[:approval].present?
        ss_id = params[:ssid]
        shocardid = params[:shocardid]
        session_id = Rails.cache.read("ss.session.#{ss_id}")
        Rails.cache.write("session.state.#{session_id}", shocardid)
      else
        #no action on the site if user has rejected the register request
      end
    rescue
      status = 422 #something went wrong
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

end
