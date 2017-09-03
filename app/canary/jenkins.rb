require 'httparty'

module CodeValet
  module Canary
    class Jenkins
      URL_BASE = ENV['JENKINS_URL_BASE'] || 'https://codevalet.io'

      # https://codevalet.io/u/codevalet/userContent/builtOn.txt
      def self.rebuiltAlpha
        return self.rebuiltUrlFor('codevalet')
      end

      def self.rebuiltGa
        return self.rebuiltUrlFor('rtyler')
      end

      def self.rebuiltUrlFor(user)
        url = "#{URL_BASE}/u/#{user}/userContent/builtOn.txt"
        response = HTTParty.get(url)
        if response.ok?
          return response.body
        end
        return 'failed to retrieve last built information..'
      end
    end
  end
end
