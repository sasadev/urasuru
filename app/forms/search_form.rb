# 検索フォームのための汎用モデル
class SearchForm
	include ActiveModel::Model

	class_attribute :_search_model
	class_attribute :_like_attributes
	class_attribute :_equal_attributes
	class_attribute :_in_attributes
	class_attribute :_join_tables

	self._like_attributes  = []
	self._equal_attributes = []
	self._in_attributes    = []
	self._join_tables   = []

	def t
		_search_model.arel_table
	end

	class << self

		def search(query={})
			new(query).search
		end

		def generate_objects(params = {}, opt = { per: 30 })
			retry_ = false
			begin
				sql_condition_code = opt[:controller_name]
				unless opt[:no_save]
					sql_condition = SqlCondition.find_or_initialize_by(
							code:          sql_condition_code || _search_model.to_s.underscore,
							admin_id: opt[:admin].try(:id)
					)

					if params[:query]
						sql_condition.condition = YAML.dump(params[:query])
					end
					search_form = new(YAML::load(sql_condition.condition))
				else
					search_form = new(params[:query])
				end

				opt[:paginate] = false if params[:csv_generate]

				if opt[:paginate] == false
					objects = search_form.search
				else
					objects = search_form.search.page(params[:page]).per(opt[:per])
				end

				objects = objects.order(params[:order]) if params[:order]
				objects = objects.order(opt[:order]) if opt[:order]

				unless opt[:no_save]
					sql_condition.save!
				end
			rescue => e
				p e
				puts e.backtrace
				params[:query] = nil
				unless retry_
					retry_ = true
					retry
				else
					search_form = new
					objects     = search_form.search.page(params[:page]).per(opt[:per])
				end
			ensure
				return objects, search_form
			end
		end

		private
		def inherited(child)
			child._search_model = child.name.gsub('SearchForm', '').constantize
		end

		def define_attribute(*attrs)
			attrs.each do |attr|
				if attr.respond_to?(:each)
					attr.each do |attr2|
						define_method attr2 do
							instance_variable_get(%Q|@#{attr2}|)
						end
						define_method %Q|#{attr2}=| do |val|
							instance_variable_set(%Q|@#{attr2}|, val)
						end
					end
				else
					define_method attr do
						instance_variable_get(%Q|@#{attr}|)
					end
					define_method %Q|#{attr}=| do |val|
						instance_variable_set(%Q|@#{attr}|, val)
					end
				end
			end

		end

		public
		def search_model(attr)
			self._search_model = attr
		end

		def like_attributes(*attrs)
			define_attribute attrs
			if attrs.respond_to?(:each)
				attrs.each do |attr|
					self._like_attributes += [attr]
				end
			else
				self._like_attributes += [attrs[0]]
			end
		end

		def equal_attributes(*attrs)
			define_attribute attrs
			if attrs.respond_to?(:each)
				attrs.each do |attr|
					self._equal_attributes += [attr]
				end
			else
				self._equal_attributes += [attrs[0]]
			end
		end

		def in_attributes(*attrs)
			define_attribute attrs
			if attrs.respond_to?(:each)
				attrs.each do |attr|
					self._in_attributes += [attr]
				end
			else
				self._in_attributes += [attrs[0]]
			end
		end

		def join_tables(*attrs)
			define_attribute attrs
			if attrs.respond_to?(:each)
				attrs.each do |attr|
					self._join_tables += [attr]
				end
			else
				self._join_tables += [attrs[0]]
			end
		end
	end

	def date_check(attr=[])
		attr.each do |i|
			next if i.blank?
			i.to_date
		end
	end

	def search
		scoped = _search_model.all
		_like_attributes.each do |attr|
			scoped = scoped.where _search_model.arel_table[attr].matches("%#{send(attr)}%") if send(attr).present?
		end

		_equal_attributes.each do |attr|
			scoped = scoped.where _search_model.arel_table[attr].eq(send(attr)) if send(attr).present?
		end

		_in_attributes.each do |attr|
			send(attr).try(:reject!) { |c| c.empty? }
			next if send(attr).blank?
			scoped = if send(attr).respond_to?(:each)
								 scoped.where _search_model.arel_table[attr].in(send(attr))
							 else
								 scoped.where _search_model.arel_table[attr].in([send(attr)])
							 end
		end

		_join_tables.each do |model|
			scoped = scoped.includes model
		end

		scoped = custom_hook(scoped) if defined? custom_hook

		scoped
	end

end