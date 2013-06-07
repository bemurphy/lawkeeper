require 'spec_helper'

class Post; end
class PostPolicy; end
class SpecifiedPolicy; end

describe Lawkeeper::PolicyLookup, '.[]' do
  it "returns PostPolicy for a Post instance" do
    Lawkeeper::PolicyLookup[Post.new].must_equal PostPolicy
  end

  it "prefers the classes policy_class if available" do
    post = Post.new
    klass = Class.new do
      def self.policy_class
        SpecifiedPolicy
      end
    end
    Lawkeeper::PolicyLookup[klass].must_equal SpecifiedPolicy
  end

  it "raises NotDefined if the policy can not be found" do
    lambda {
      Lawkeeper::PolicyLookup[Object.new]
    }.must_raise(Lawkeeper::NotDefined)
  end
end

describe Lawkeeper::PolicyLookup, '.for_scope' do
  it "calls to the Lawkeeper.scope_finder" do
    class ForScope; end
    class ForScopePolicy; end
    Lawkeeper.scope_finder = Proc.new { |s| s.class.name }

    Lawkeeper::PolicyLookup.for_scope(ForScope.new).must_equal ForScopePolicy
  end
end
