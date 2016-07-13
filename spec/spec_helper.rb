$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'liquid_vector_graphic'
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }
require 'pry'
