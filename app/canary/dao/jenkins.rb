require 'faraday'
require 'canary/dao'
require 'raven'

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
      response = connection.get(url)
      if response.success?
        return response.body
      end
      @error = response.status
      return nil
    rescue *CodeValet::Canary::DAO::NET_ERRORS => e
      @error = e
      return nil
    rescue StandardError => e
      @error = e
      Raven.capture_exception(e)
      return nil
    end

    private

    def connection
      return Faraday.new(:ssl => {:verify => true}) do |f|
        f.adapter Faraday.default_adapter
        f.options.timeout = 4
        f.options.open_timeout = 3
      end
    end


    def cache
      return CodeValet::Canary::DAO.cache
    end
  end
end
