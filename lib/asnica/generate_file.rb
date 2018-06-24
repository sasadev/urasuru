# -*- encoding: UTF-8 -*-
include ActionView::Helpers::NumberHelper
module Asnica
  module GenerateFile
    extend self

    def thin_reports_tmp(add_dir="")
      exist_dir( "#{Rails.root}/resources/thin_reports")
      return exist_dir( "#{Rails.root}/resources/thinreports/#{"#{add_dir}/" unless add_dir.blank?}")
    end
    def thin_reports_output(add_dir="")
      exist_dir( "#{Rails.root}/tmp/thin_reports")
      return exist_dir( "#{Rails.root}/tmp/thin_reports/#{"#{add_dir}/" unless add_dir.blank?}")
    end
    ["order"].each do|add_name|
      define_method("thin_reports_#{add_name}_tmp") {thin_reports_tmp(add_name)}
      define_method("thin_reports_#{add_name}_output") {thin_reports_output(add_name)}
    end
    def purchase_layout() "#{thin_reports_order_tmp}purchase.tlf";end
    def purchase_output(order) "#{file_tmp}purchase_#{order.id}.pdf";end


    def exist_dir(tmp_dir)
      unless File.exist?(tmp_dir)
        Dir::mkdir(tmp_dir)
        s = File::stat(Rails.root)
        File::chown(s.uid, s.gid, tmp_dir)
      end
      return tmp_dir
    end
    def file_tmp(add_dir="")
      return exist_dir( "#{Rails.root}/tmp/file/#{"#{add_dir}/" unless add_dir.blank?}")
    end
    def con_sjis(str,cast=nil)
      case cast
        when :utf8
          str.to_s.kconv(Kconv::UTF8, Kconv::SJIS)
        else
          str.to_s.kconv(Kconv::SJIS, Kconv::UTF8)
      end
    end
    def create_file_name(name,path=nil,sym="")
      "#{file_tmp if path}#{name + file_format}#{sym}"
    end
    def file_format
      day = Time.now
      file = day.strftime("%Y%m%d-%H%M%S")
      return file
    end
    def file_directory(file_type)
      directory = {
          "generate" => {:directory => "#{Rails.root}/tmp/file/"},
          "csv" => {:directory => "#{Rails.root}/tmp/file/", :extension => ".csv"},
          "report_file" => {:directory => "#{Rails.root}/tmp/file/"},
          "txt" => {:directory => "#{Rails.root}/tmp/file/", :extension => ".txt"}
      }
      return directory[file_type]
    end
    def generate_csv(bodys,headers,opt={})
      row_cnt = 0
      csv_data = CSV.generate("", {:row_sep => "\r\n", :headers => headers, :write_headers => true}) do |csv|
        bodys.each_with_index do |body,idx|
          row_cnt += 1
          details =  file_layout.file_layout_details.map do |detail|
            layout_key = detail.file_layout_key
            eval(layout_key ? "#{layout_key.method_code}" : "detail.get_body(headers.blank? ? idx : (idx+1))")
          end
          if other_result
            details += other_result[:bodys].map{|i|eval(i)}
          end
          csv <<  details
        end
      end
      return csv_data.tosjis
    end

#http://rubydoc.info/gems/axlsx/1.0.15/frames
#http://rubydoc.info/github/randym/axlsx/Axlsx/Worksheet
#https://code.google.com/p/axlsx/source/browse/axlsx_examples.wiki?repo=wiki
    def xlsx_header_style
      {
          :fg_color=> "FF00000",
          :bg_color => "FFF0E6BE",
          :b => true,
          :name=>"ＭＳ 明朝",
          :sz => 14,
          :border => {:style => :thin, :color => "FF333333"},
          :alignment => {:horizontal => :center, :vertical => :center}
      }
    end
    def xls_body_style
      {
          :name=>"ＭＳ 明朝",
          :sz => 12,
          :border => {:style => :thin, :color => "FF333333"},
          :alignment => {:horizontal => :center, :vertical => :center}
      }
    end

    def xlsx_opt
      {
          :style   => {:header => xlsx_header_style ,:body => xls_body_style} ,
          :width   => {:text=>:auto,:image=>16.25},
          :height   => 20,
      }
    end

    def generate_xlsx(bodys,headers,opt={})

      pkg = Axlsx::Package.new
      pkg.workbook do |wb|
        wb.add_worksheet(:name => '一覧') do |ws|
          header_style = ws.styles.add_style(xlsx_opt[:style][:header])
          body_style   = ws.styles.add_style(xlsx_opt[:style][:body])

          styles = [] ; widths = []
          headers.size.times do |i|
            styles  << body_style
            widths  << xlsx_opt[:width][:text]
          end
          ws.add_row headers,:style => headers.map{|i| header_style} unless headers.blank?
          height = xlsx_opt[:height]
          bodys.each do |body|
            rows = body
            ws.add_row rows,:style => styles, :height => height, :widths=>widths
          end

        end
      end
      return pkg
    end
    def from_fullkana_to_halfkana(str)
      h={"ガ"=>"ｶﾞ","ギ"=>"ｷﾞ","グ"=>"ｸﾞ","ゲ"=>"ｹﾞ","ゴ"=>"ｺﾞ",
         "ザ"=>"ｻﾞ","ジ"=>"ｼﾞ","ズ"=>"ｽﾞ","ゼ"=>"ｾﾞ","ゾ"=>"ｿﾞ",
         "ダ"=>"ﾀﾞ","ヂ"=>"ﾁﾞ","ヅ"=>"ﾂﾞ","デ"=>"ﾃﾞ","ド"=>"ﾄﾞ",
         "バ"=>"ﾊﾞ","ビ"=>"ﾋﾞ","ブ"=>"ﾌﾞ","ベ"=>"ﾍﾞ","ボ"=>"ﾎﾞ",
         "パ"=>"ﾊﾟ","ピ"=>"ﾋﾟ","プ"=>"ﾌﾟﾞ","ペ"=>"ﾍﾟﾞ","ポ"=>"ﾎﾟ",
         "ヴ"=>"ｳﾞ","ア"=>"ｱ","イ"=>"ｲ","ウ"=>"ｳ","エ"=>"ｴ","オ"=>"ｵ",
         "カ"=>"ｶ","キ"=>"ｷ","ク"=>"ｸ","ケ"=>"ｹ","コ"=>"ｺ",
         "サ"=>"ｻ","シ"=>"ｼ","ス"=>"ｽ","セ"=>"ｾ","ソ"=>"ｿ",
         "タ"=>"ﾀ","チ"=>"ﾁ","ツ"=>"ﾂ","テ"=>"ﾃ","ト"=>"ﾄ",
         "ナ"=>"ﾅ","ニ"=>"ﾆ","ヌ"=>"ﾇ","ネ"=>"ﾈ","ノ"=>"ﾉ",
         "ハ"=>"ﾊ","ヒ"=>"ﾋ","フ"=>"ﾌ","ヘ"=>"ﾍ","ホ"=>"ﾎ",
         "マ"=>"ﾏ","ミ"=>"ﾐ","ム"=>"ﾑ","メ"=>"ﾒ","モ"=>"ﾓ",
         "ヤ"=>"ﾔ","ユ"=>"ﾕ","ヨ"=>"ﾖ",
         "ラ"=>"ﾗ","リ"=>"ﾘ","ル"=>"ﾙ","レ"=>"ﾚ","ロ"=>"ﾛ",
         "ワ"=>"ﾜ","ヲ"=>"ｦ","ン"=>"ﾝ",
         "ャ"=>"ｬ","ュ"=>"ｭ","ョ"=>"ｮ",
         "ァ"=>"ｧ","ィ"=>"ｨ","ゥ"=>"ｩ","ェ"=>"ｪ","ォ"=>"ｫ",
         "ッ"=>"ｯ","゛"=>"ﾞ", "゜"=>"ﾟ","ー"=>"ｰ","！"=>"!","　"=>" ","）"=>")"}
      str_after=""
      str.to_s.split("").each{|str_one|
        str_after+= h[str_one.to_s] ? h[str_one.to_s] : str_one.to_s
      }
      return str_after
    end
    protected
  end
end
