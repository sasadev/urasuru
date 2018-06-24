# -*- encoding: UTF-8 -*-
module Asnica
  module Base

    extend self
    # p instance_variable_get("@#{controller_name}")
    # instance_variable_set(:@title, "Programming Ruby 1.9")
    def create_klass(model,opt={})
      eval("#{model.to_s.camelize}.new(opt)",)
    end
    def long_transaction
     # @errors = @errors || Array.new
      errors__ = []

      ActiveRecord::Base.transaction do
        begin
          yield
        rescue => e
          Asnica::AsnicaLogger.create(e)
          if e.kind_of? ActiveRecord::RecordInvalid

            errors__ << e.record.errors.messages.keys.map{|key| e.record.errors.messages[key]}
            errors__ << e if errors__.flatten.blank?
          else
            errors__ << e
          end
          raise ActiveRecord::Rollback
        end
      end
      return errors__.flatten
    end
    def strip_html_tags(str)
      ActionView::Base.full_sanitizer.sanitize(str.to_s).gsub("\n","").gsub("&#13;","")
    end


    def holiday_?(tmp_date)
      return  tmp_date.wday.to_i == 0 || tmp_date.wday.to_i == 6 || tmp_date.national_holiday?
    end
    def decode_key(str)
      p d_str = str.to_s.encode("UTF-16BE",NKF.guess(str.to_s).to_s, :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
      return d_str
    rescue => e
      p e
      return ""
    end
    def what_day_count(today=Time.now)
      return today.strftime("%j").to_i
    end

    def sort_hash(key,opt={})
      hash_key = key.to_sym
      return [] unless opt[hash_key]
      return opt[hash_key].keys.sort{|a, b|
        a.to_i <=> b.to_i
      }.map{|i|
        h = {}
        opt[hash_key][i].keys.each{|key2|h[key2.to_sym] =  opt[hash_key][i][key2] }
        h
      }
    end

    def paginate_opt(opt={},action="index")
      u_opt = action.is_a?(Hash) ? action :  {:action =>action}
      opt.merge({
                    :params       => u_opt,
                    :window       => 3,
                    :outer_window => 3,
                })
    end
    def generate_paginate(objects,opt={})
      objects.page(opt[:page] || 1).per(opt[:per] || 20).order(opt[:order] || :id)
    end

    def valid_date?(_date_from_,_date_to_)
      _today_ = Date.today
      _date_from_ = _date_from_ ? _date_from_.to_date : nil
      _date_to_   = _date_to_   ? _date_to_.to_date : nil

      return true if _date_from_.blank? && _date_to_.blank?
      return (case true
                when !_date_from_.blank? && !_date_to_.blank?
                  _date_from_ <= _today_ && _date_to_ >= _today_
                when !_date_from_.blank?
                  _date_from_ <= _today_
                when !_date_to_.blank?
                  _date_to_ >= _today_
              end) ? true : nil
    end
    def exist_date?(tmp_date)
      tmp_date_arr = tmp_date.to_s.split("-")
      return  Date.valid_date?(tmp_date_arr[0].to_i,tmp_date_arr[1].to_i,tmp_date_arr[2].to_i)
    end
    def date_join(date_sym,opt)
      "#{opt["#{date_sym}(1i)"]}-#{opt["#{date_sym}(2i)"]}-#{opt["#{date_sym}(3i)"]}"
    end

    def date_join_and_exist_date?(date_sym,opt)
      exist_date? date_join(date_sym,opt)
    end

    def to_round(num,opt={})
      return 0 if num.to_f.infinite? == 1
      return 0 if num.to_f.nan?
      num = num.round(opt[:round].blank? ? 2 : opt[:round].to_i )
      return num
    end

    def text_sub(txt,sym1=/(\n)/,sym2='<br />')
      txt.to_s.gsub(sym1,sym2)
    end
    # 文字が多いとき"..."を付ける
    def text_abbr(txt, len,sym="...")
      txt = to_zen(txt)
      text=text.gsub(" ", "").gsub(/\<br\>/i, " ").gsub(/\<br\/\>/i, " ")
      if text != nil
        if text.jlength < len
          return text
        else
          text=text.scan(/^.{#{len}}/m)[0] + sym
          return text
        end
      else
        return ""
      end
    end
    # 全角を半角に変換
    def to_zen(value)
      # str_1 = Moji.han_to_zen(value, Moji::HAN_ALPHA)
      # str_2 = Moji.han_to_zen(str_1, Moji::HAN_KATA)
      # str_3 = Moji.han_to_zen(str_2, Moji::HAN_ASYMBOL)
      # str_4 = Moji.han_to_zen(str_3, Moji::HAN_NUMBER)
      return value.to_zen
    end
    # 全角を半角に変換
    def to_email(email)
      Moji.zen_to_han(Moji.downcase(email.to_s))
    end
    def all_ok?(bool1,bool2=true,bool3=true,bool4=true,bool5=true,bool6=true,bool7=true,bool8=true)
      bools=[bool1,bool2,bool3,bool4,bool5,bool6,bool7,bool8]
      return bools.all?{|bo| bo == true}
    end

    def loading_open
      "$.winPause().open();"
    end
    def loading_close
      "$.winPause().close();"
    end

    def index_color
      {
          "0"=>  "#1e90ff",
          "1"=>  "#90ee90",
          "2"=>  "#daa520",
          "3"=>  "#ff00ff",
          "4"=>  "#faebd7",
          "5"=>  "#bdb76b",
          "6"=>  "#6495ed",
          "7"=>  "#00ff7f",
          "8"=>  "#cd853f",
          "9"=>  "#ff00ff",
          "10"=>  "#ffefd5",
          "11"=>  "#f0ffff",
          "12"=>  "#7fffd4",
          "13"=>  "#f4a460",
          "14"=>  "#ffb6c1",
          "15"=>  "#fffaf0",
          "16"=>  "#0000ff",
          "17"=>  "#98fb98",
          "18"=>  "#ff8c00",
          "19"=>  "#d8bfd8",

          "20"=>  "#f8f8ff",
          "21"=>  "#00bfff",
          "22"=>  "#faf0e6",
          "23"=>  "#b8860b",
          "24"=>  "#ee82ee",
          "25"=>  "#ffebcd",
          "26"=>  "#87cefa",
          "27"=>  "#7cfc00",
          "28"=>  "#d2691e",
          "29"=>  "#dda0dd",
          "30"=>  "#ffe4c4",
          "31"=>  "#87ceeb",
          "32"=>  "#7fff00",
          "33"=>  "#a0522d",
          "34"=>  "#da70d6",
          "35"=>  "#ffe4b5",
          "36"=>  "#add8e6",
          "37"=>  "#adff2f",
          "38"=>  "#8b4513",
          "39"=>  "#ba55d3",
          "40"=>  "#ffdead",
          "41"=>  "#b0e0e6",
          "42"=>  "#00ff00",
          "43"=>  "#800000",
          "44"=>  "#9932cc",
          "45"=>  "peachpu",
          "46"=>  "#ffdab9",
          "47"=>  "#afeeee",
          "48"=>  "#32cd32",
          "49"=>  "#8b0000",
          "50"=>  "#9400d3",
          "51"=>  "mistyro",
          "52"=>  "#ffe4e1",
          "53"=>  "#e0ffff",
          "54"=>  "#9acd32",
          "55"=>  "#a52a2a",
          "56"=>  "#8b008b",
          "57"=>  "#fff0f5",
          "58"=>  "#00ffff",
          "59"=>  "#556b2f",
          "60"=>  "#b22222",
          "61"=>  "#800080",
          "62"=>  "#fff5ee",
          "63"=>  "#00ffff",
          "64"=>  "#6b8e23",
          "65"=>  "#cd5c5c",
          "66"=>  "#4b0082",
          "67"=>  "#fdf5e6",
          "68"=>  "#40e0d0",
          "69"=>  "#808000",
          "70"=>  "#bc8f8f",
          "71"=>  "#483d8b",
          "72"=>  "#fffff0",
          "73"=>  "#48d1cc",
          "74"=>  "#00fa9a",
          "75"=>  "#e9967a",
          "76"=>  "#8a2be2",
          "77"=>  "#f0fff0",
          "78"=>  "#00ced1",
          "79"=>  "#eee8aa",
          "80"=>  "#f08080",
          "81"=>  "#9370db",
          "82"=>  "#f5fffa",
          "83"=>  "#20b2aa",
          "84"=>  "#fff8dc",
          "85"=>  "#fa8072",
          "86"=>  "#6a5acd",
          "87"=>  "#0000cd",
          "88"=>  "#5f9ea0",
          "89"=>  "#f5f5dc",
          "90"=>  "#ffa07a",
          "91"=>  "#7b68ee",
      }
    end

    protected

  end
end