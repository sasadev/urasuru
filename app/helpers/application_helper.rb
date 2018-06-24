module ApplicationHelper

  # 共通のものを記載する
  def error_html(msg)
    raw "<p class=\"formErrorTxt\" style=\"margin-bottom: 10px;color: red;\">#{msg}</p>"
  end

  def error_message_on_txt(msg)
    return nil if msg.blank?
    error_html(msg)
  end

  def notice_helper(notice)
    if notice.text?
      return notice.title
    elsif notice.link?
      return link_to notice.title, notice.url
    elsif notice.tab?
      return link_to notice.title, notice.url, target: '_blank'
    else notice.popup?
    return link_to_modal notice.title, { url: top_page_notices_path(notice)}
    end
  end

  def error_message_on(object, method)
    obj = nil
    if object.is_a?(String) || object.is_a?(Symbol)
      method = method.to_sym
      obj = instance_variable_get("@#{object}")
    else
      obj = object
    end

    if obj
      if obj.errors.include?(method)
        messages = obj.errors.messages[method]
        error_html("#{obj.class.human_attribute_name(method)}#{messages.first}")
      end
    end
  end

end