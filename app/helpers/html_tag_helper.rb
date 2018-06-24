# -*- encoding: UTF-8 -*-
module HtmlTagHelper
####################################
#         link_to_remote           #
####################################

	JS_ESCAPE_MAP = {
			'\\'    => '\\\\',
			'</'    => '<\/',
			"\r\n"  => '\n',
			"\n"    => '\n',
			"\r"    => '\n',
			'"'     => '\\"',
			"'"     => "\\'"
	}

	CALLBACKS    = Set.new([ :complete, :error ] +
														 (100..599).to_a)

	JS_ESCAPE_MAP["\342\200\250"] = '&#x2028;'

	def escape_javascript(javascript)
		if javascript
			result = javascript.gsub(/(\\|<\/|\r\n|\342\200\250|[\n\r"'])/u) {|match| JS_ESCAPE_MAP[match] }
			javascript.html_safe? ? result.html_safe : result
		else
			''
		end
	end

	def link_to_remote(name, options = {}, html_options = {})
		link_to_function(name, remote_function(options), html_options || options.delete(:html))
	end

	def link_to_function(name, function, html_options={})
		onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
		href = html_options[:href] || '#'
		content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
	end

	def remote_function(options={})
		javascript_options = options_for_ajax(options)
		callbacks          = build_callbacks(options)

		function = ""

		update = ''
		if options[:update] && options[:update].is_a?(Hash)
			update = []
			update << "success:'#{options[:update][:success]}'" if options[:update][:success]
			update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
			update = '{' + update.join(',') + '}'
		elsif options[:update]
			update << "'#{options[:update]}'"
		end

		function << "jQuery.ajax({"
		function << "type: '#{options[:method] ? options[:method] : 'GET'}',"
		function << "url:  '#{options[:url] ? url_for(options[:url]) : '#'}',"
		function << "data: #{javascript_options},"
		callbacks.each { |callback,code| function << "#{callback.to_s}: #{code}, " } if callbacks.present?
		function << "success: function(data) {"
		function << options[:success] + '; ' if options[:success].present?
		function << if options[:position]
									case options[:position].to_sym
										when :top
											"jQuery('##{options[:update]}').prepend(data); "
										when :bottom
											"jQuery('##{options[:update]}').append(data); "
										when :before
											"jQuery('##{options[:update]}').before(data); "
										when :after
											"jQuery('##{options[:update]}').after(data); "
										else
											"jQuery('##{options[:update]}').html(data); "
									end
								else
									"jQuery('##{options[:update]}').html(data); "
								end
		function << "} });"

		function = "#{options[:before]}; #{function}" if options[:before]
		function = "#{function}; #{options[:after]};" if options[:after]
		function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
		function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]
		return function.html_safe
	end

	def options_for_ajax(options)
		js_options={}
		if options[:submit]
			js_options['parameters'] = "jQuery('##{options[:submit]} input, ##{options[:submit]} textarea,  ##{options[:submit]} select, ##{options[:submit]}').serialize('')"
		elsif options[:with]
			js_options['parameters'] = options[:with]
		else
		  return js_options['parameters'] = "jQuery('form :not([name=\"_method\"])').serialize(this)"
		end

		unless !options[:submit] && !options[:with]
			if protect_against_forgery? && !options[:form]
				if js_options['parameters']
					js_options['parameters'] << " + '&"
				else
					js_options['parameters'] = "'"
				end
				js_options['parameters'] << "#{request_forgery_protection_token}=' + encodeURIComponent('#{escape_javascript form_authenticity_token}')"
			end
		end
	end

	def build_callbacks(options)
		callbacks = {}
		options.each do |callback, code|
			if CALLBACKS.include?(callback)
				callbacks[callback] = "function(request){#{code}}"
			end
		end
		return callbacks
	end

	def method_option_to_s(method)
		(method.is_a?(String) and !method.index("'").nil?) ? method : "'#{method}'"
	end

	def link_to_modal(name, options = {}, html_options = {})
		options[:update] = "modal-body"
		html_options.merge!( data: { toggle: "modal",
																 target: "#admin-modal" } )
		link_to_remote(name, options, html_options)
	end

	def link_to_favorite( options = {}, html_options = {} )
		if options[:id]
			options = favorite_opt(options)
			raw("<span id=\"favorite_#{options[:id]}\">" + link_to_remote(options[:name], options, html_options) + "</span>")
		end
	end

	def favorite_opt(options={})
		movie = Movie.available_records.find_by(id: options[:id])

		if @current_user.favorite_movies.include?(movie)
			options[:name] = "Remove from favorites"
			options[:url]  = remove_from_favorite_path(id: movie.id)
		else
			options[:name] = "Add to favorites"
			options[:url]  = add_to_favorite_path(id: movie.id)
		end

		options[:update] = "favorite_#{options[:id]}"

		options
	end

	def favicon_link_tag(source='favicon.ico', options={})
		tag('link', {
				:rel  => 'shortcut icon',
				:type => 'image/x-icon',
				:href => path_to_image(source)
		}.merge!(options.symbolize_keys))
	end

end
