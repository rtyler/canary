
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/app')

ENV['RACK_ENV'] ||= 'development'

require 'canary'
require 'raven'

use Rack::Static, :urls => ['/css', '/img', '/js'], :root => 'public'
use Raven::Rack

run CodeValet::Canary::App
