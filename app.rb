require 'sinatra'
require 'sequel'
require 'logger'

if ENV.key? 'DATABASE_URL'
  DB = Sequel.connect ENV['DATABASE_URL']
  raise 'Not migrated' unless DB.table_exists?(:items)
else
  DB = Sequel.sqlite
  require './migrate'
end
DB.loggers << Logger.new(STDOUT) if ENV['RACK_ENV'] != 'production'


helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @items = DB[:items].all
  haml :index, :format => :html5
end

post '/' do
  return 'Forgot to send something' unless params[:title]
  
  DB[:items] << {:user_id => 0, :title => params[:title], :created_at => Time.now}
  redirect '/'
end
