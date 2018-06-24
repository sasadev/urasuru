class Admin::ContactsController < Admin::BaseController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :destroy

  def index
    query = params
    search_remained(query)
    @contacts, @query = ContactSearchForm.generate_objects(admin_query_params, admin: @current_admin)
    @contacts = @contacts.decorate
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
    if @contact.update(contact_params)
      redirect_to edit_admin_contact_path(@contact), notice: t('activerecord.flash.contact.actions.update.success')
    else
      render :edit
    end
  end

  def destroy
    if @contact.soft_delete
      redirect_to admin_contacts_path, notice: t('activerecord.flash.contact.actions.destroy.success')
    else
      flash[:alert] = t('activerecord.flash.contact.actions.destroy.failure')
      redirect_to admin_contacts_path
    end
  end

  private

  def set_contact
    @contact = Contact.custom_find_by(id: params[:id]).decorate
  end

  def contact_params
    params.require(:contact).permit!
  end
end