require 'spec_helper'

class Post; end
class PostPolicy; end
class SpecifiedPolicy; end

describe Lawkeeper::PolicyLookup do
  it "returns PostPolicy for a Post instance" do
    Lawkeeper::PolicyLookup[Post.new].must_equal PostPolicy
  end

  it "prefers the instance#policy_class if available" do
    post = Post.new
    def post.policy_class
      SpecifiedPolicy
    end
    Lawkeeper::PolicyLookup[post].must_equal SpecifiedPolicy
  end

  it "raises NotDefined if the policy can not be found" do
    lambda {
      Lawkeeper::PolicyLookup[Object.new]
    }.must_raise(Lawkeeper::NotDefined)
  end
end
