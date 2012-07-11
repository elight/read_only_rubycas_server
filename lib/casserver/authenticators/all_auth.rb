# encoding: UTF-8
require 'casserver/authenticators/base'

class CASServer::Authenticators::AllAuth < CASServer::Authenticators::Base
  def validate(credentials)
    true
  end
end
