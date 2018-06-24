# Abstract class for ActiveModel::Model
class BasicRecord::Base002

	include ActiveModel::Model
	def attributes=(params)
		params.each do |k, v|
			send("#{k}=", v.html_safe)
		end
	end
	class << self

		def find(_id)
			data = base_data.find{ |i| i[:id] == _id }
			if data.blank?
				nil
			else
				new(data)
			end
		end

		def find_by(condition={})
			data = base_data.find { |i|
				condition.find do |key, val|
					i[key] == val
				end
			}

			if data.blank?
				nil
			else
				new(data)
			end
		end

		def all
			base_data.map do |data|
				new data
			end
		end
		def where(opt={})
			all.map {|data|
				data	unless opt.keys.map{|key|data.send(key) ==  opt[key] }.include?(false)
			}.compact
		end

		def pluck(*column)
			all.map do |i|
				if column.is_a? Array
					column.map { |col| i.send(col) }
				else
					i.send(column)
				end
			end
		end
	end

end
