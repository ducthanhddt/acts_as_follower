require "acts_as_follower/version"

module ActsAsFollower
  autoload :Follower,     'acts_as_follower/follower'
  autoload :Followable,   'acts_as_follower/followable'
  autoload :FollowerLib,  'acts_as_follower/follower_lib'
  autoload :FollowScopes, 'acts_as_follower/follow_scopes'

  module MyCustomDeprecation
    def self.warn(message, callstack = caller)
      # Log the message to a file, or handle it however you need
      Rails.logger.warn("Deprecation Warning: #{message}")
      Rails.logger.warn("Called from: #{callstack.join("\n")}")
    end
  end

  def self.setup
    @configuration ||= Configuration.new
    yield @configuration if block_given?
  end

  def self.method_missing(method_name, *args, &block)
    if method_name == :custom_parent_classes=
      ActsAsFollower::MyCustomDeprecation.warn("Setting custom parent classes is deprecated and will be removed in future versions.")
    end
    @configuration.respond_to?(method_name) ?
        @configuration.send(method_name, *args, &block) : super
  end

  class Configuration
    attr_accessor :custom_parent_classes

    def initialize
      @custom_parent_classes = []
    end
  end

  setup

  require 'acts_as_follower/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3
end
