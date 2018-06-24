class ContactSearchForm < SearchForm

  equal_attributes :status

  like_attributes :name

  def custom_hook(scoped)
    scoped.order(contact_at: :desc)
  end
end