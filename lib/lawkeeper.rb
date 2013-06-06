require "lawkeeper/version"

module Lawkeeper
  AUTHORIZED_HEADER = 'Lawkeeper-Authorized'.freeze
  SKIPPED_HEADER    = 'Lawkeeper-Skipped'.freeze

  class NotAuthorized < StandardError; end
  class NotDefined < StandardError; end

  class Policy
    attr_reader :user, :record

    def initialize(user, record)
      @user   = user
      @record = record
    end
  end

  class PolicyLookup
    def self.[](model)
      if model.respond_to?(:policy_class)
        model.policy_class
      else
        begin
          Object.const_get("#{model.class}Policy")
        rescue NameError
          raise NotDefined
        end
      end
    end
  end

  module Helpers
    def can?(action, model, policy_class = nil)
      policy_class ||= Lawkeeper::PolicyLookup[model]
      policy_method = "#{action}?"
      policy_class.new(current_user, model).public_send(policy_method)
    end

    def authorize(model, action, policy_class = nil)
      if can?(action, model, policy_class)
        headers[AUTHORIZED_HEADER] = 'true'
      else
        raise NotAuthorized
      end
    end

    def skip_authorization
      headers[SKIPPED_HEADER] = 'true'
    end
  end

  class EnsureWare
    def initialize(app, options = {})
      @app     = app
      @options = options
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      status, headers, body = @app.call(env)

      if headers.delete(AUTHORIZED_HEADER) || headers.delete(SKIPPED_HEADER)
        [status, headers, body]
      else
        [status_code, {"Content-Type" => "text/plain"}, ['forbidden, authorization required']]
      end
    end

    def status_code
      @options.fetch(:status_code, 403)
    end
  end

  class ScrubWare
    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      status, headers, body = @app.call(env)
      headers.delete(AUTHORIZED_HEADER)
      headers.delete(SKIPPED_HEADER)
      [status, headers, body]
    end
  end
end
