# frozen_string_literal: true

module Core
    APPLICATION_ENV = ENV['APPLICATION_ENV'] || 'development'
    def self.require_source
      require 'dotenv/load'
      require 'telegram/bot'
      require 'pry'
      require 'yaml'
      require 'active_record'
  
      #Dir['./app/*/*.rb'].each { |file| require_relative file }
      #Dir['./core/*.rb'].each { |file| require_relative file }
      #Dir['./config/initializers/*.rb'].each { |file| require_relative file }
    end
  end
  