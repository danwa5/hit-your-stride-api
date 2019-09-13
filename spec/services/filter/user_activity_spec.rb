require 'rails_helper'

RSpec.describe Filter::UserActivity do
  describe '.call' do
    before do
      @a1 = create(:user_activity, city: 'San Francisco', country: 'United States')
      @a2 = create(:user_activity, city: 'Toronto', country: 'Canada')
      @a3 = create(:user_activity, city: 'Los Angeles', country: 'United States')
    end

    context 'when there are no search params' do
      it 'returns all' do
        res = described_class.call({})
        expect(res).to contain_exactly(@a1, @a2, @a3)
      end
    end

    context 'when search param is { city: "toronto"}' do
      it 'returns 1' do
        res = described_class.call({ city: 'toronto'})
        expect(res).to contain_exactly(@a2)
      end
    end

    context 'when search param is { country: "united states" }' do
      it 'returns 2' do
        res = described_class.call({ country: 'united states' })
        expect(res).to contain_exactly(@a1, @a3)
      end
    end

    context 'when search param is { city: "LA" }' do
      it 'returns none' do
        res = described_class.call({ city: 'LA' })
        expect(res).to be_empty
      end
    end
  end
end
