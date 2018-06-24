class Admin::TagsController < Admin::BaseController
  before_action :set_tag, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :destroy

  def index
    query = params
    search_remained(query)
    @tags, @query = TagSearchForm.generate_objects(admin_query_params, admin: @current_admin)
  end

  def show
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)

    sort = Tag.where(use_model: @tag.use_model).last.try(:sort_seq)
    if sort.present?
      @tag.sort_seq = (sort.to_i + 1)
    else
      @tag.sort_seq = 1
    end
    if @tag.save
      redirect_to edit_admin_tag_path(@tag), notice: t('activerecord.flash.tag.actions.create.success')
    else
      flash.now[:alert] = t('activerecord.flash.tag.actions.create.failure')
      render :new
    end
  end

  def edit
  end

  def update
    if @tag.update(tag_params)
      redirect_to edit_admin_tag_path(@tag), notice: t('activerecord.flash.tag.actions.update.success')
    else
      render :edit
    end
  end

  def destroy
    if @tag.soft_delete
      redirect_to admin_tags_path, notice: t('activerecord.flash.tag.actions.destroy.success')
    else
      flash[:alert] = t('activerecord.flash.tag.actions.destroy.failure')
      redirect_to admin_tags_path
    end
  end

  def sort
    if request.post?
      begin
        Tag.transaction do
          params[:tag_contents].each.with_index(1) do |tag_id,i|
            tag = Tag.find_by(id: tag_id)
            tag.update!(sort_seq: i)
          end
        end
        flash[:notice] = "並び順の変更をしました"
      rescue => e
        p e
        flash[:alert] = "並び順の変更時にエラーが起こりました"
      end
    end

    redirect_to action: :index
  end

  def mod_use_models
    @tag = Tag.find_or_initialize_by(id: params[:id])
    @tag.attributes = tag_params

    render partial: "form"
  end

  private
  def set_tag
    @tag = Tag.find_by(id: params[:id])
  end

  def tag_params
    params.require(:tag).permit!
  end
end