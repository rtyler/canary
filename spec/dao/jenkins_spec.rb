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
        expect(subject).to receive(:rebuilt_for).and_return(response)
      end

      it 'provides a response on #rebuilt_alpha' do
        expect(subject.rebuilt_alpha).to eql(response)
      end

      it 'provides a response on #rebuilt_ga' do
        expect(subject.rebuilt_ga).to eql(response)
      end

      it 'should cache subsequent calls on #rebuilt_alpha' do
        3.times do
          expect(subject.rebuilt_alpha).to eql(response)
        end
      end

      it 'should cache subsequent calls on #rebuilt_ga' do
        3.times do
          expect(subject.rebuilt_ga).to eql(response)
        end
      end
    end
  end

  context 'with network errors' do
    it 'should silently handle ECONNRESET' do
      expect(subject).to receive(:connection).and_raise(Errno::ECONNRESET)

      expect(subject.rebuilt_ga).to be_nil
      expect(subject).to be_errored
    end
  end

  context 'with unknown errors' do
    it 'should record an exception and return nil' do
      expect(subject).to receive(:connection).and_raise(JSON::ParserError)
      expect(Raven).to receive(:capture_exception)

      expect(subject.rebuilt_ga).to be_nil
      expect(subject).to be_errored
    end
  end
end
