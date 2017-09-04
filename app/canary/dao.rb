require 'concurrent/hash'
require 'mini_cache'

module CodeValet
  module Canary
    # The DAO module contains some data-access objects which are to be used
    # from the web tier.
    module DAO
      # Unless otherwise specified, cached entries should "live" for this
      # number of seconds
      DEFAULT_CACHE_SECONDS = 120

      # Access the caching object
      #
      # @returs [MiniCache::Store]
      def self.cache
        return @cache unless @cache.nil?

        @cache = MiniCache::Store.new
        @cache.instance_variable_set(:@data, Concurrent::Hash.new)
        return @cache
      end

      # Reset the cache, primarily intended for testing
      def self.clear_cache
        @cache = nil
      end
    end
  end
end
