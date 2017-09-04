require 'faraday'
require 'canary/dao'

module CodeValet::Canary::DAO
  class Jenkins
    # Base URL to contrict 
    URL_BASE = ENV['JENKINS_URL_BASE'] || 'https://codevalet.io'
    CACHE_SECONDS = 300

    attr_reader :error

    def errored?
      return !@error.nil?
    end

    def rebuiltAlpha
      return cache.get_or_set('rebuiltAlpha', :expires_in => CACHE_SECONDS) do
        rebuiltFor('codevalet')
      end
    end

    def rebuiltGA
      return cache.get_or_set('rebuiltGA', :expires_in => CACHE_SECONDS) do
        rebuiltFor('rtyler')
      end
    end

    # Method for directly querying a Jenkins instance to ask when it was last
    # rebuilt
    #
    # @return [String] response from the server if we reached it
    # @return [nil] nil on no response, #errored? should be set
    def rebuiltFor(user)
      # NOTE: worth investigating whether Jenkins will provide the appropriate
      # caching headers to 
      url = "#{URL_BASE}/u/#{user}/userContent/builtOn.txt"
      response = Faraday.get(url)
      if response.success?
        return response.body
      end
      @error = response.status
      return nil
    end

    private
    def cache
      return CodeValet::Canary::DAO.cache
    end
  end
end
