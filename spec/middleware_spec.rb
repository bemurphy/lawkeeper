require 'spec_helper'

describe Lawkeeper, 'middlewares' do
  describe Lawkeeper::EnsureWare do
    it "returns the result of calling the app if Lawkeeper-Authorized is 'true'"
    it "returns the result of calling the app if Lawkeeper-Skipped is 'true'"
    it "returns the result of calling the app if no Lawkeeper header is set"
    it "deletes the lawkeeper headers"
  end

  describe Lawkeeper::ScrubWare do
    it "deletes the lawkeeper headers"
  end
end
