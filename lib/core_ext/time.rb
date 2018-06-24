class Time
  def strftime_at(sep=" ")
    self.strftime("%Y-%m-%d#{sep}%H:%M:%S").to_s.html_safe
  end
end