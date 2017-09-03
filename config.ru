
$LOAD_PATH << File.dirname(__FILE__)

ENV['RACK_ENV'] ||= 'development'

require 'app'
require 'raven'

use Rack::Static, :urls => ["/css", "/img", "/js"], :root => "public"
use Raven::Rack

run CodeValet::Canary::App
