	require 'uri'
class Admin::BaseController < ApplicationController
	# ssl_required :all
	# before_filter :auth_basic if BASIC_AUTHNTICATION_ADMIN

	layout "admin"

	before_action :allowed_ip?

	before_action :authenticate!,
								:set_breadcrumbs,
								:has_role?

	class_attribute :require_write_permission_actions


	def allowed_ip?
		reject_ip = false
		remote_ips = ALLOW_IP_FOR_ADMIN.dup
		if IP_RESTRICTION_FOR_ADMIN
			reject_ip = true unless remote_ips.include?(request.remote_ip)
		end
		if reject_ip
			session[:person_id] = nil
			return redirect_to("/")
		end
	end

	def self.write_permission_required(*actions, &blk)
		self.require_write_permission_actions ||= []
		self.require_write_permission_actions += actions
	end

	def authenticate!
		if  @current_admin_user = AdminUser.alive_record(id: session[:admin_user_id], deleted: 0)
			# redirect_to admin_root_path
		else
			redirect_to admin_login_path
		end
	end

	def has_role?
		# @current_form = Form.find_by(code: controller_name)
		# @form_read  = @current_admin.role_read?(controller_name)
		# @form_write = @current_admin.write_read?(controller_name)

		require_write_permission_actions  = self.class.require_write_permission_actions || []
		require_write_permission_actions += [:new, :create, :edit, :update, :destroy]

		current_path = request.path.gsub("/admin/","").split("/").first
		#
		# # unless @current_admin.has_role?(current_path)
		# unless @current_admin.has_role?(controller_name)
		# 	return render "admin/page/no_access_right", layout: !request.xhr?
		# end
		#
		# if require_write_permission_actions.include?(action_name.to_sym)
		# 	unless @current_admin.has_write_role?(controller_name)
		# 		return render "admin/page/no_access_right", layout: !request.xhr?
		# 	end
		# end
	end

	def set_breadcrumbs
		add_breadcrumb "Home", admin_root_path

		add_breadcrumb t("views.admin.#{controller_name}.title"), eval("admin_#{controller_name}_path")
		add_breadcrumb t("views.admin.#{controller_name}.actions.#{action_name}")


		# current_paths = request.path.gsub("/admin/","").split("/").reject { |path| path.number? }
		# current_paths.each do |current_path|
		# 	begin
		# 		add_breadcrumb t("views.admin.#{current_path}.title"), eval("admin_#{current_path}_path")
		# 	rescue => e
		# 		p current_path
		# 		add_breadcrumb t("views.admin.#{current_path}.title")
		# 	end
		# end
		#
		# add_breadcrumb t("views.admin.#{controller_name}.actions.#{action_name}")
	end

	def get_file
		file_name = "#{Asnica::GenerateFile.file_tmp}#{params[:file_name]}"

		send_file file_name
	rescue => e
		p e
	end


	protected
	# 自動ログアウトする場合
	def reset_session_expires
		if session[:expires_at] && session[:expires_at] < Time.current
			session[:admin_user_id] = nil
			session[:expires_at]    = nil
		else
			session[:expires_at] = Time.current + 30.minutes
		end
	end

	def admin_query_params
		params[:query] ||= {}
		return params.to_unsafe_h
	end

	def search_remained(params)
		if params[:query].blank?
			sql_condition = SqlCondition.find_or_initialize_by(
					code: name_singularize.to_s.underscore,
					admin_id: @current_admin.id
			)
			if sql_condition && sql_condition.condition.present?
				params[:query] = YAML::load(sql_condition.condition)
			end
		end
		return params
	end

	def name_singularize
		controller_name.singularize
	end

end