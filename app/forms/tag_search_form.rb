class TagSearchForm < SearchForm
  attr_accessor :deleted_at
  attr_accessor :tag_mode

  like_attributes :name


  def custom_hook(scoped)
    scoped = scoped.alive_records

    case tag_mode
      when 'use_society' then
        scoped = scoped.use_societies
      when 'use_notification' then
        scoped = scoped.use_notifications
      else
        scoped = scoped.use_seminars
    end

    scoped.order(sort_seq: :asc)
  end
end
