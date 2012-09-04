unless Object.const_defined? 'DB'
  raise 'Not given a database to migrate' unless ENV.key? 'DATABASE_URL'
  
  require 'sequel'
  require 'logger'

  DB = Sequel.connect ENV['DATABASE_URL']
  DB.loggers << Logger.new(STDOUT) if ENV['RACK_ENV'] != 'production'
end

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

  # Some test data
  if ENV['RACK_ENV'] != 'production'
    [
      'Make a pretty to-do template',
      'Apply the template to the other apps too',
      'Make to-dos actually work',
      'Party hard',
    ].each do |seed|
      DB[:items] << {:user_id => 0, :title => seed, :created_at => Time.now}
    end
  end
end

