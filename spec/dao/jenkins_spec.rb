require 'spec_helper'

require 'json'
require 'canary/dao/jenkins'

describe CodeValet::Canary::DAO::Jenkins do
  before :each do
    CodeValet::Canary::DAO.clear_cache
  end

  context 'a bare instance' do
    it { should_not be_errored }

    context 'with a stubbed network call' do
      let(:response) { 'stubbed!' }
      before :each do
        expect(subject).to receive(:rebuiltFor).and_return(response)
      end

      it 'provides a response on #rebuiltAlpha' do
        expect(subject.rebuiltAlpha).to eql(response)
      end

      it 'provides a response on #rebuiltGA' do
        expect(subject.rebuiltGA).to eql(response)
      end

      it 'should cache subsequent calls on #rebuiltAlpha' do
        3.times do
          expect(subject.rebuiltAlpha).to eql(response)
        end
      end

      it 'should cache subsequent calls on #rebuiltGA' do
        3.times do
          expect(subject.rebuiltGA).to eql(response)
        end
      end
    end
  end

  context 'with network errors' do
    it 'should silently handle ECONNRESET' do
      expect(subject).to receive(:connection).and_raise(Errno::ECONNRESET)

      expect(subject.rebuiltGA).to be_nil
      expect(subject).to be_errored
    end
  end

  context 'with unknown errors' do
    it 'should record an exception and return nil' do
      expect(subject).to receive(:connection).and_raise(JSON::ParserError)
      expect(Raven).to receive(:capture_exception)

      expect(subject.rebuiltGA).to be_nil
      expect(subject).to be_errored
    end
  end
end
