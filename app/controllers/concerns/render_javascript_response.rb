# RJSで書かれている古いコードをなるべく簡単に動かすためのヘルパー
module RenderJavascriptResponse
  # === Usage
  # render_javascript_response do |page|
  #   page.replace_html 'myid', 'hello'
  # end
  def render_javascript_response
    context = PageContext.new
    context.controller = self
    yield(context)
    response['Content-Type'] = response.content_type = 'text/javascript'
    render plain: context.code
  end

  private
  class PageContext
    include ActionView::Helpers::JavaScriptHelper

    attr_reader :code
    attr_writer :controller

    def initialize
      @code = ''
    end

    def replace_html(id, html)
      if html.is_a?(Hash) # partial: 'mypartialname'
        html = @controller.render_to_string(html)
      end
      @code << "jQuery('##{id}').html('#{escape_javascript html}');"
    end

    def redirect_to(url)
      if url.is_a?(Hash)
        url = @controller.url_for(url)
      end
      @code << "window.location.href = '#{escape_javascript url}';"
    end

    def show(id)
      @code << "jQuery('##{id}').show();"
    end

    def hide(id)
      @code << "jQuery('##{id}').hide();"
    end
    def alert(str)
      @code << "alert('#{str}');"
    end
    def anchor(id,offset=150,speed=500)
      @code <<  "$(\"html, body\").animate({scrollTop:$(\"##{id}\").offset().top - #{offset}}, #{speed}, \"swing\");"
    end
    def script(script)
      @code << "#{script};"
    end
  end
end