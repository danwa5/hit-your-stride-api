require 'rails_helper'

RSpec.describe 'Locations', type: :request do
  describe 'GET /api/v1/locations' do
    it 'returns all locations' do
      create(:user_activity, city: 'San Francisco', state_province: 'CA', country: 'US')
      create(:user_activity, city: 'Toronto', state_province: 'ON', country: 'CA')
      create(:user_activity, city: 'Portland', state_province: 'OR', country: 'US')
      create(:user_activity, city: 'San Francisco', state_province: 'CA', country: 'US')

      get api_v1_locations_path

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json['results'].size).to eq(3)

      aggregate_failures 'results' do
        expect(json['results'][0]).to eq(
          {
            'id' => nil,
            'type' => 'location',
            'attributes' => {
              'city' => 'Portland',
              'state_province' => 'OR',
              'country' => 'US'
            }
          }
        )

        expect(json['results'][1]).to eq(
          {
            'id' => nil,
            'type' => 'location',
            'attributes' => {
              'city' => 'San Francisco',
              'state_province' => 'CA',
              'country' => 'US'
            }
          }
        )

        expect(json['results'][2]).to eq(
          {
            'id' => nil,
            'type' => 'location',
            'attributes' => {
              'city' => 'Toronto',
              'state_province' => 'ON',
              'country' => 'CA'
            }
          }
        )
      end
    end
  end
end
