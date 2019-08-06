require 'rails_helper'

RSpec.describe 'Activities', type: :request do
  describe 'GET /api/v1/activities' do
    before do
      create_list(:user_activity, 3)
    end
    it do
      get '/api/v1/activities'

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json.size).to eq(3)
    end
  end
end
