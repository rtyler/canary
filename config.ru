
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/app')

ENV['RACK_ENV'] ||= 'development'

require 'canary'
require 'raven'

# Skip over Sinatra entirely for static assets
use Rack::Static, :urls => ['/css', '/img', '/js'], :root => 'assets'
use Raven::Rack

run CodeValet::Canary::App
