class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :destroy

  def index
    query = params
    search_remained(query)
    @users, @query = UserSearchForm.generate_objects(admin_query_params, admin: @current_admin)
    respond_to do |format|
      format.html do
        @users = @users&.decorate
      end
      format.csv do
        file_name = Asnica::GenerateFile.create_file_name('users',nil,'.csv')
        send_data render_to_string, filename: file_name, type: :csv
      end
    end
  end

  def show
  end

  def new
    @user = User.new
    @user.addresses.build
  end

  def create
    @user = User.new(admin_user_params)
    begin
    User.transaction do
      @user.save!
      UserHistory.new.save_change_history(@user)
    end
    redirect_to edit_admin_user_path(@user), notice: t('activerecord.flash.user.actions.create.success')
    rescue => e
      p e
      flash.now[:alert] = t('activerecord.flash.user.actions.create.failure')
      render :new
      end
  end

  def edit
  end

  def update
    begin
    User.transaction do
      @user.update!(admin_user_params)
      UserHistory.new.save_change_history(@user, UserHistory.admin_update_user[:code])
    end
    redirect_to edit_admin_user_path(@user), notice: t('activerecord.flash.user.actions.update.success')
    rescue => e
      p e
      flash.now[:alert] = t('activerecord.flash.user.actions.update.failure')
      render :edit
      end
  end

  def destroy
    if @user.soft_delete
      redirect_to admin_users_path, notice: t('activerecord.flash.user.actions.destroy.success')
    else
      flash[:alert] = t('activerecord.flash.user.actions.destroy.failure')
      redirect_to admin_users_path
    end
  end

  def postcode_search
    idx = params[:idx]

    address_opt = admin_user_params[:addresses_attributes][idx]
    postcode_list = PostCodeList.postcode_find({postcode: "#{address_opt[:postcode]}"})
    render_javascript_response do |page|
      if postcode_list
        page.code << "$(\"#user_addresses_attributes_#{idx}_prefecture_id\").val(\"#{postcode_list.pref}\");"
        page.code << "$(\"#user_addresses_attributes_#{idx}_city\").val(\"#{postcode_list.city}\");"
        page.code << "$(\"#user_addresses_attributes_#{idx}_town\").val(\"#{postcode_list.town}\");"
        page.code << "$(\"#user_addresses_attributes_#{idx}_building\").focus();"
      else
        page.alert '郵便番号が見つかりませんでした'
      end
    end
  rescue => e
    Asnica::AsnicaLogger.create(e)

  end

  private

  def set_user
    @user = User.custom_find_by(id: params[:id])
  end

  def admin_user_params
    params.require(:user).permit(User.permit_params) if params[:user]
  end
end