require 'haml'
require 'raven'
require 'sinatra/base'
require 'sentry-api'

require 'canary/dao/jenkins'
require 'canary/dao/sentry'

module CodeValet
  module Canary
    # Basic Canary web app entry point.
    class App < Sinatra::Base
      enable  :sessions
      enable  :raise_errors
      disable :show_exceptions

      set :public_folder, File.dirname(__FILE__) + '/../assets'
      set :views, File.dirname(__FILE__) + '/../views'

      SentryApi.configure do |config|
        config.endpoint = 'https://app.getsentry.com/api/0'
        config.auth_token = ENV['SENTRY_API_TOKEN']
        config.default_org_slug = 'codevalet'
      end

      get '/' do
        haml :index,
             :layout => :_base,
             :locals => {
               :sentry => DAO::Sentry.new,
               :jenkins => DAO::Jenkins.new,
             }
      end

      get '/issue/:id' do
        sentry = DAO::Sentry.new
        issue_id = params['id']

        haml :issue,
             :layout => :_base,
             :locals => {
               :issue => sentry.issue_by(issue_id),
               :events => sentry.events_for_issue(issue_id),
             }
      end
    end
  end
end
