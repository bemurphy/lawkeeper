require 'spec_helper'

class User
  attr_accessor :permit
end

class Comment
  attr_accessor :permit
end

class CommentPolicy < Lawkeeper::Policy
  def read?
    user.permit && record.permit
  end
end

describe Lawkeeper::Helpers do
  let(:comment) { Comment.new }
  let(:controller) {
    c = Object.new.tap { |c| c.extend(Lawkeeper::Helpers) }
    def c.current_user
      @current_user ||= User.new
    end

    def c.headers
      @headers ||= {}
    end

    c
  }

  def permit_action
    controller.current_user.permit = true
    comment.permit = true
  end

  describe '#can?' do
    it "returns false for a user denied action" do
      controller.current_user.permit = true
      comment.permit = false
      controller.can?(:read, comment).must_equal false

      controller.current_user.permit = false
      comment.permit = true
      controller.can?(:read, comment).must_equal false
    end

    it "returns true for a user permitted action" do
      permit_action
      controller.can?(:read, comment).must_equal true
    end

    it "can receive a specified policy class" do
      klass = Class.new(Lawkeeper::Policy) do
        def read?
          true
        end
      end
      controller.can?(:read, comment, klass).must_equal true
    end
  end

  describe '#authorize' do
    it "sets the authorized header to 'true' if the user can run the action" do
      permit_action
      controller.authorize(comment, :read)
      controller.headers['Lawkeeper-Authorized'].must_equal 'true'
    end

    it "skips setting the header if Lawkeeper.skip_set_headers is true" do
      Lawkeeper.skip_set_headers = true

      permit_action
      controller.authorize(comment, :read)
      controller.headers['Lawkeeper-Authorized'].must_be_nil 'true'

      Lawkeeper.skip_set_headers = nil
    end

    it "raises NotAuthorized if the user is not permitted the action" do
      lambda {
        controller.authorize(comment, :read)
      }.must_raise(Lawkeeper::NotAuthorized)
    end

    it "can receive a specified policy class" do
      klass = Class.new(Lawkeeper::Policy) do
        def read?
          true
        end
      end
      controller.authorize(comment, :read, klass)
    end
  end

  describe '#skip_authorization' do
    it "sets the authorized header to 'true'" do
      controller.skip_authorization
      controller.headers['Lawkeeper-Skipped'].must_equal 'true'
    end
  end
end
