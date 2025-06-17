require 'yaml'
require 'active_record'

env = ENV['RACK_ENV'] || 'development'
db_config = YAML.load_file(File.expand_path('../db/config.yml', __dir__))

ActiveRecord::Base.establish_connection(db_config[env])
