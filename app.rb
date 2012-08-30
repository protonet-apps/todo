require 'sinatra'
require 'sequel'
require 'logger'

DB = if ENV.key? 'DATABASE_URL'
  Sequel.connect ENV['DATABASE_URL']
else
  Sequel.sqlite
end
DB.loggers << Logger.new(STDOUT)

unless DB.table_exists? :items
  DB.create_table :items do
    primary_key :id

    Fixnum :user_id, :null => false
    index :user_id
    String :title, :null => false

    DateTime :created_at, :null => false
    index :created_at
    DateTime :updated_at
    DateTime :completed_at
  end

  [
    'Make a pretty to-do template',
    'Apply the template to the other apps too',
    'Make to-dos actually work',
    'Party hard',
  ].each do |seed|
    DB[:items] << {:user_id => 0, :title => seed, :created_at => Time.now}
  end
end

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
