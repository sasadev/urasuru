class Admin::AdminUsersController < Admin::BaseController
  before_action :set_admin_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :destroy

  def index
    query = params
    search_remained(query)
    @admin_users, @query = AdminUserSearchForm.generate_objects(admin_query_params, admin: @current_admin_user)
  end

  def search
  end

  def show
  end

  def new
    @admin_user = AdminUser.new
  end

  def create
    @admin_user = AdminUser.new(admin_user_params)

    if @admin_user.save
      redirect_to edit_admin_admin_user_path(@admin_user), notice: t('activerecord.flash.admin_user.actions.create.success')
    else
      flash.now[:alert] = t('activerecord.flash.admin_user.actions.create.failure')
      render :new
    end
  end

  def edit
  end

  def update
    if @admin_user.update(admin_user_params)
      redirect_to edit_admin_admin_user_path(@admin_user), notice: t('activerecord.flash.admin_user.actions.update.success')
    else
      render :edit
    end
  end

  def destroy
    if @admin_user.soft_delete
      redirect_to admin_admin_user_path, notice: t('activerecord.flash.admin_user.actions.destroy.success')
    else
      flash[:alert] = t('activerecord.flash.admin_user.actions.destroy.failure')
      redirect_to admin_admin_user_path
    end
  end

  private
  def set_admin_user
    @admin_user = AdminUser.find_by(id: params[:id])
  end

  def admin_user_params
    params.require(:admin_user).permit!
  end
end