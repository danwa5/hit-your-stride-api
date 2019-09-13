require 'rails_helper'

RSpec.describe 'Activities', type: :request do
  describe 'GET /api/v1/activities' do
    before do
      expect(Filter::UserActivity).to receive(:call).and_call_original
    end

    it 'returns all data' do
      create_list(:user_activity, 3)

      get '/api/v1/activities'

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json['results'].size).to eq(3)
    end

    context 'when a permitted search param is given' do
      it 'returns the correct data' do
        @a1 = create(:user_activity, city: 'San Francisco', country: 'United States')
        @a2 = create(:user_activity, city: 'Toronto', country: 'Canada')

        get '/api/v1/activities?city=toronto'

        json = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(json['results'].size).to eq(1)
        expect(json['results'][0]['id']).to eq(@a2.id.to_s)
      end
    end
  end
end
