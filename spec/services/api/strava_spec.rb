require 'rails_helper'

RSpec.describe Api::Strava do
  describe '.base_uri' do
    it { expect(described_class.base_uri).to eq('https://www.strava.com/api') }
  end

  describe '.format' do
    it { expect(described_class.format).to eq(:json) }
  end

  describe '.get_profile' do
    it 'makes a request to strava api' do
      stub_req = stub_request(:get, 'https://www.strava.com/api/v3/athlete').to_return(status: 200)

      response = described_class.get_profile

      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end

  describe '.get_activities_list' do
    it 'makes a request to strava api and returns an array of activities' do
      stub_req = stub_request(:get, %r{https://www.strava.com/api/v3/athlete/activities\?after=\d+}).to_return(status: 200)

      response = described_class.get_activities_list

      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end

  describe '.get_activity' do
    it 'makes a request to strava api and returns an activity' do
      stub_req = stub_request(:get, 'https://www.strava.com/api/v3/activities/101').to_return(status: 200)

      response = described_class.get_activity({ uid: 101 })

      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end
end
