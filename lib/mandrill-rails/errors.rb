module Mandrill::Rails::Errors
  Base                = Class.new(StandardError)
  MissingEventHandler = Class.new(Base)
end
