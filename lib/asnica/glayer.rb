class Asnica::Glayer
	class << self
		def show(id='glayer')
      return ""
			"Glayer.show('#{id}');"
		end
		def hide(id='glayer')
      return ""
			"Glayer.hide('#{id}');"
		end
		def fadeIn(id,opt={})
      return ""
			"Glayer.fadeIn('#{id}');"
		end
		def fadeOut(opt={})
      return ""
			"Glayer.fadeOut('glayer', {duration: #{opt[:duration]}});"
		end
	end
end