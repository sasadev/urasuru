class AdminSearchForm < SearchForm
  attr_accessor :deleted_at

  like_attributes :name,
                  :email


  def custom_hook(scoped)
    scoped = scoped.alive_records

    scoped.order(id: :desc)
  end
end
