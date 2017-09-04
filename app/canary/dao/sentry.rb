require 'faraday'

require 'canary/dao'
require 'raven'
require 'sentry-api'

module CodeValet::Canary::DAO
  class Sentry
    attr_reader :error

    CACHE_SECONDS = 60

    def errored?
      return !@error.nil?
    end

    # Return a list of the configured/accessible projects from Sentry
    #
    # if there is an error, check #errored? and #error
    #
    # @return [Array]
    # @return [nil] in case of an error
    def projects
      # Caching the response for a long time since Sentry projects are not
      # added/changed very often
      return cache.get_or_set('SentryApi#projects',
                              :expires_in => 10 * CACHE_SECONDS) do
        SentryApi.projects
      end
    rescue *CodeValet::Canary::DAO::NET_ERRORS => e
      @error = e
      return []
    rescue StandardError => e
      @error = e
      Raven.capture_exception(e)
      return []
    end

    # Fetch an array of recent issues for the given project
    #
    # @param [String] project_key is the Sentry project 'slug'
    # @return [Array]
    # @return [nil] in case of error
    def issues_for(project_key)
      return cache.get_or_set("SentryApi#project_issues(#{project_key})",
                              :expires_in => CACHE_SECONDS) do

        SentryApi.project_issues(project_key)
      end
    rescue *CodeValet::Canary::DAO::NET_ERRORS => e
      @error = e
      return []
    rescue StandardError => e
      @error = e
      Raven.capture_exception(e)
      return []
    end

    private

    def cache
      return CodeValet::Canary::DAO.cache
    end
  end
end
