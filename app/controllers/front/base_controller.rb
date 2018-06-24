require 'uri'
class Front::BaseController < ApplicationController
	layout 'front'
	before_action :maintenance_mode?
	before_action :login_user

	def maintenance_mode?
		if MAINTE_MODE
			unless MAINTE_ALLOW_IP.include?(request.remote_ip)
				return redirect_to("/maintenance")
			end
		end
		return redirect_to('/maintenance') if MAINTE_MODE && !MAINTE_ALLOW_IP.include?(request.remote_ip)
	end

	def login
		@login_user = User.authenticate(params[:login_user])
		if @login_user
			session[:user_id] = @login_user.id
		else
			flash.now[:login_alert] = 'メールアドレスまたはパスワードが正しくありません。もう一度試してください。'
		end
	end

	def logout
		session[:user_id] = nil
		redirect_to root_path
	end

	def login_user
		@login_user = User.alive_records.find_by(id: session[:user_id])
	end
end