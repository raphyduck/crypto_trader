require 'bundler/setup'
require 'hanami/mailer'

#Process.daemon

class Trader

  def initialize
    #Require libraries
    Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
    #Require app file
    require File.dirname(__FILE__) + '/init.rb'
  end

  def self.run
    Speaker.speak_up('Welcome to your crypto trader assistant!

')
    Dispatcher.dispatch(ARGV)
  end

  def self.leave
    Speaker.speak_up("End of session, good bye...")
  end
end

Trader.new
Trader.run
Trader.leave