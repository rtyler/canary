require 'spec_helper'

require 'canary/dao'

describe CodeValet::Canary::DAO do
  it { should respond_to :cache }
  it { should respond_to :clear_cache }
end
