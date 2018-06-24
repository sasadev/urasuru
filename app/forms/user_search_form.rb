class UserSearchForm < SearchForm
  attr_accessor :deleted_at

  equal_attributes :id

  like_attributes :last_name
  like_attributes :first_name
  like_attributes :email
  like_attributes :tel

  def custom_hook(scoped)
    scoped = scoped.alive_records
    scoped.order(id: :desc)
  end
end