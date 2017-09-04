require 'spec_helper'

require 'json'

require 'canary/dao/sentry'

describe CodeValet::Canary::DAO::Sentry do
  before :each do
    CodeValet::Canary::DAO.clear_cache
  end

  context 'a bare instance' do
    it { should_not be_errored }
  end

  it { should respond_to :projects }
  describe '#projects' do
    let(:projects) { ['stub project'] }

    it 'should return SentryApi#projects' do
      expect(SentryApi).to receive(:projects).and_return(projects)

      expect(subject.projects).to eql(projects)
    end

    it 'should gracefully handle network errors' do
      expect(SentryApi).to receive(:projects).and_raise(Errno::ECONNRESET)

      expect(subject.projects).to be_empty
      expect(subject).to be_errored
    end

    it 'should gracefully handle and record unknown errors' do
      expect(SentryApi).to receive(:projects).and_raise(JSON::ParserError)
      expect(Raven).to receive(:capture_exception)

      expect(subject.projects).to be_empty
      expect(subject).to be_errored
    end

    it 'should cache the response from SentryApi#projects' do
      expect(SentryApi).to receive(:projects).and_return(projects)

      3.times do
        expect(subject.projects).to eql(projects)
      end
    end
  end

  it { should respond_to :issues_for }
  describe '#issues_for' do
    let(:dao) { described_class.new }
    subject(:issues) { dao.issues_for('rspec') }
    let(:response) { ['stub issue'] }

    it 'should return SentryApi#project_issues' do
      expect(SentryApi).to receive(:project_issues).and_return(response)
      expect(issues).to eql(response)
    end

    it 'should gracefully handle network errors' do
      expect(SentryApi).to receive(:project_issues).and_raise(Errno::ECONNRESET)
      expect(issues).to be_empty
      expect(dao).to be_errored
    end

    # https://github.com/CodeValet/canary/issues/5
    it 'should gracefully handle Sentry API parsing errors' do
      expect(SentryApi).to receive(:project_issues).and_raise(SentryApi::Error::Parsing)
      expect(Raven).not_to receive(:capture_exception)

      expect(issues).to be_empty
      expect(dao).to be_errored
    end

    it 'should gracefully handle and record unknown errors' do
      expect(SentryApi).to receive(:project_issues).and_raise(JSON::ParserError)
      expect(Raven).to receive(:capture_exception)

      expect(issues).to be_empty
      expect(dao).to be_errored
    end

    it 'should cache the response from SentryApi#project_issues' do
      expect(SentryApi).to receive(:project_issues).and_return(response)
      3.times do
        expect(dao.issues_for('rspec')).to eql(response)
      end
    end
  end

  it { should respond_to :issue_by }
  describe '#issue_by' do
    let(:dao) { described_class.new }
    subject(:issue) { dao.issue_by('fake-id') }
    let(:response) { Hash.new }

    it 'should return SentryApi#issue' do
      expect(SentryApi).to receive(:issue).and_return(response)
      expect(issue).to eql(response)
    end

    it 'should gracefully handle network errors' do
      expect(SentryApi).to receive(:issue).and_raise(Errno::ECONNRESET)
      expect(issue).to be_nil
      expect(dao).to be_errored
    end

    it 'should gracefully handle and record unknown errors' do
      expect(SentryApi).to receive(:issue).and_raise(JSON::ParserError)
      expect(Raven).to receive(:capture_exception)

      expect(issue).to be_nil
      expect(dao).to be_errored
    end

    it 'should cache the response from SentryApi#issue' do
      expect(SentryApi).to receive(:issue).and_return(response)
      3.times do
        expect(dao.issue_by('fake-id')).to eql(response)
      end
    end
  end

  it { should respond_to :events_for_issue }
  describe '#events_for_issue' do
    let(:dao) { described_class.new }
    subject(:issue) { dao.events_for_issue('fake-id') }
    let(:response) { Hash.new }

    it 'should return SentryApi#issue' do
      expect(SentryApi).to receive(:issue_events).and_return(response)
      expect(issue).to eql(response)
    end

    it 'should gracefully handle network errors' do
      expect(SentryApi).to receive(:issue_events).and_raise(Errno::ECONNRESET)
      expect(issue).to be_nil
      expect(dao).to be_errored
    end

    it 'should gracefully handle and record unknown errors' do
      expect(SentryApi).to receive(:issue_events).and_raise(JSON::ParserError)
      expect(Raven).to receive(:capture_exception)

      expect(issue).to be_nil
      expect(dao).to be_errored
    end

    it 'should cache the response from SentryApi#issue' do
      expect(SentryApi).to receive(:issue_events).and_return(response)
      3.times do
        expect(dao.events_for_issue('fake-id')).to eql(response)
      end
    end
  end
end
