module Asnica
  module Regex
    extend self
    require 'resolv'
#https://gist.github.com/nashirox/38323d5b51063ede1d41
    def username_regex
      default_regex
    end
    def email_regex
      # /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
      #/\A[\w+\-.\/.]+@[a-z\d\-.]+\.[a-z]+\z/i
      /\A([^@\s,]+)@((?:[-a-z0-9A-Z]+\.)+[-a-z0-9A-Z]{2,})\z/
    end

    def project_name_regex
      /\A[a-zA-Z][a-zA-Z0-9_\-\. ]*\z/
    end

    def code_regex
      /\A[a-zA-Z0-9_\-\.]*\z/
    end
    def zip_regex
      /\A\d{7}\z/
    end
    def zip1_regex
      /\A\d{3}\z/
    end
    def zip2_regex
      /\A\d{4}\z/
    end
    def num_regex
      /\A[0-9]+\z/
    end
    def zen_kana_regex
      /\A[ァ-ンー－　ヴ]+\z/
    end

    def tag_regex
      /\A[a-zA-Z0-9_@\-\. ]*\z/
    end

    def path_regex
      default_regex
    end

    def ip_address_v4
      Resolv::IPv4::Regex
    end

    def only_num_az
      /^[ a-zA-Z0-9]+$/
    end


    protected

    def default_regex
      /\A[a-zA-Z][a-zA-Z0-9_\-\.]*\z/
    end
  end
end
