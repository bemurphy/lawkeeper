require "lawkeeper/version"

module Lawkeeper
  AUTHORIZED_HEADER = 'Lawkeeper-Authorized'.freeze
  SKIPPED_HEADER    = 'Lawkeeper-Skipped'.freeze

  class NotAuthorized < StandardError; end
  class NotDefined < StandardError; end

  class << self
    attr_accessor :skip_set_headers, :scope_finder
  end

  class Policy
    attr_reader :user, :record

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user  = user
        @scope = scope
      end

      def resolve
        scope
      end
    end

    def initialize(user, record)
      @user   = user
      @record = record
    end
  end

  class PolicyLookup
    def self.[](model)
      klass = model.is_a?(Class) ? model : model.class

      if klass.respond_to?(:policy_class)
        klass.policy_class
      else
        begin
          Object.const_get("#{klass}Policy")
        rescue NameError
          raise NotDefined
        end
      end
    end

    def self.for_scope(scope)
      model_name = Lawkeeper.scope_finder.call(scope)
      self[Object.const_get(model_name)]
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
        set_lawkeeper_header(AUTHORIZED_HEADER)
      else
        raise NotAuthorized
      end
    end

    def policy_scope(scope)
      set_lawkeeper_header(AUTHORIZED_HEADER)
      klass = Lawkeeper::PolicyLookup.for_scope(scope)::Scope
      klass.new(current_user, scope).resolve
    end

    def skip_authorization
      set_lawkeeper_header(SKIPPED_HEADER)
    end

    def set_lawkeeper_header(header)
      headers[header] = 'true' unless Lawkeeper.skip_set_headers
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
