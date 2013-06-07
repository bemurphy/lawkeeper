require 'spec_helper'
require "lawkeeper/scope_finders/active_record"
require "lawkeeper/scope_finders/ohm"

describe Lawkeeper::ScopeFinders::ActiveRecord do
  it "returns the .model_name of the passed scope" do
    o = Object.new
    def o.model_name
      "Comment"
    end
    Lawkeeper::ScopeFinders::ActiveRecord.call(o).must_equal "Comment"
  end
end

describe Lawkeeper::ScopeFinders::Ohm do
  it "returns the first portion of the .key for the passed scope" do
    o = Object.new
    def o.key
      "Comment:1"
    end
    Lawkeeper::ScopeFinders::Ohm.call(o).must_equal "Comment"
  end
end
