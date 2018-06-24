=begin
卵カートプラス用エクセプション

※ここでメール送るかどうかを考え中
=end
module Asnica
  module AsnicaLogger
    extend self

    def create(exception)
      #予期せぬ例外の場合はここで処理
      #メールを飛ばしてもいいかも
      use_mail = Rails.env != 'development'
      p exception
      case true
        when exception.is_a?(ActiveRecord::RecordInvalid)
        when exception.is_a?(RuntimeError)
        when exception.is_a?(String),exception.is_a?(Array)
          exception.join("\n") if exception.is_a?(Array)
          if use_mail
            err ="#{exception}\n-----------------------------------------------------------------"
            #th = Thread.start(err) { |u|
              begin
                ExceptionNotifier.notify_exception(exception, env: Rails.env)
              rescue Exception => e
                p e
              end
            #}
            #th.join
          end
        else
          if use_mail
            err =["\n#{exception}\n-----------------------------------------------------------------"]
            exception.backtrace.each {|t| err << t }
            #th = Thread.start(err) { |u|
              begin
                ExceptionNotifier.notify_exception(exception, env: Rails.env)
              rescue Exception => e
                p e
              end
            #}
            #th.join
          end
          exception.backtrace.each {|t| p t }
      end

    end
  end
end


