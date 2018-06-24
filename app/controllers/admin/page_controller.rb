class Admin::PageController < Admin::BaseController
  layout false
  before_action :authenticate!, except: [ :login, :no_access_right ]
  skip_before_action :set_breadcrumbs
  skip_before_action :has_role?

  def index
    render layout: 'admin'
  end

  def no_access_right
    render layout: 'admin'
  end

  def login
    return render if request.get?
    if @admin_user = AdminUser.authenticate(admin_admin_user_params)
      session[:admin_user_id]  = @admin_user.id
      session[:admin_login_at] = Time.now

      # SqlCondition.where(admin_id: @admin).delete_all

      return redirect_to admin_admin_users_path, notice: t("messages.signed_in")
    else
      p 12333333
      flash[:alert] = t("messages.signed_in_failed")
    end
  end

  def logout
    # SqlCondition.where(admin_id: @current_admin).delete_all
    session[:admin_id] = nil
    redirect_to admin_login_path
  end

  private

  def admin_admin_user_params
    params.require(:admin_user).permit(:email, :password)
  end
end
