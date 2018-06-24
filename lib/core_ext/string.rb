# Extension String Class
class String
	def number?
		self =~ /\A-?\d+\Z/
	end

	def sjisable
		str = self
		str = str.exchange("U+301C", "U+FF5E")
		# str = str.exchange("U+FF5E", "U+301C")
		str = str.exchange("U+2212", "U+FF0D")
		str = str.exchange("U+00A2", "U+FFE0")
		str = str.exchange("U+00A3", "U+FFE1")
		str = str.exchange("U+00AC", "U+FFE2")
		str = str.exchange("U+2014", "U+2015")
		str = str.exchange("U+2016", "U+2225")
		str = str.exchange("U+FFFD", "U+30FB")
	end

	def exchange(before_str,after_str)
		self.gsub( before_str.to_code.chr('UTF-8'),
							 after_str.to_code.chr('UTF-8') )
	end

	def to_code
		return $1.to_i(16) if self =~ /U\+(\w+)/
		raise ArgumentError, "Invalid argument: #{self}"
	end

	def to_convert
		str = self
		str = str.gsub("〜","~").gsub("髙","高").gsub("﨑","崎")
		str = str.remove_break
		str = NKF.nkf('-wW -x -Z4', UNF::Normalizer.normalize(str, :nfkc).sjisable)
		str = nil if str.blank?
		str
	end

	def remove_break
		self.gsub(/(\r\n|\r|\n)/, '')
	end
	def remove_space
		self.gsub(" ", "").gsub("　", "")
	end
	def to_kana
		self.tr('ぁ-ん','ァ-ン')
	end
	# 全角を半角に変換
	def to_han
		Moji.zen_to_han(self)
	end
	# 半角を全角に変換
	def to_zen
		Moji.han_to_zen(
				Moji.han_to_zen(
						Moji.han_to_zen(
								Moji.han_to_zen(
										self,Moji::HAN_ALPHA
								),	Moji::HAN_KATA
						), Moji::HAN_ASYMBOL
				), Moji::HAN_NUMBER
		)
	end
	def to_kana_zen
		self.to_zen.to_kana
	end
end