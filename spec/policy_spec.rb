require "spec_helper"

describe Lawkeeper::Policy do
  it "is initialized with a user and record" do
    policy = Lawkeeper::Policy.new(:user, :record)
    policy.user.must_equal :user
    policy.record.must_equal :record
  end
end
