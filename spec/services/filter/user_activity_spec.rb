require 'rails_helper'

RSpec.describe Filter::UserActivity do
  describe '.call' do
    before do
      @a1 = create(:user_activity,
              city: 'San Francisco',
              country: 'United States',
              distance: 5.00,
              layoff: nil,
              mile_pace: 100,
              moving_time: 1
            )

      @a2 = create(:user_activity,
              city: 'Toronto',
              country: 'Canada',
              distance: 5.01,
              layoff: 1,
              mile_pace: 100,
              moving_time: 2
            )

      @a3 = create(:user_activity,
              city: 'Los Angeles',
              country: 'United States',
              distance: 10.00,
              layoff: 1,
              mile_pace: 101,
              moving_time: 3
            )

      @a4 = create(:user_activity,
              city: 'New York',
              country: 'United States',
              distance: 9.90,
              layoff: 2,
              mile_pace: 99,
              moving_time: nil
            )
    end

    context 'when there are no search params' do
      it 'returns all' do
        res = described_class.call({})
        expect(res).to contain_exactly(@a1, @a2, @a3, @a4)
      end
    end

    context 'when searching by city' do
      it 'returns 1' do
        res = described_class.call({ city: 'san'})
        expect(res).to contain_exactly(@a1)
      end
      it 'returns 1' do
        res = described_class.call({ city: 'toronto'})
        expect(res).to contain_exactly(@a2)
      end
      it 'returns none' do
        res = described_class.call({ city: 'LA' })
        expect(res).to be_empty
      end
      it 'returns all' do
        res = described_class.call({ city: '' })
        expect(res).to contain_exactly(@a1, @a2, @a3, @a4)
      end
    end

    context 'when searching by country' do
      it 'returns 2' do
        res = described_class.call({ country: 'united states' })
        expect(res).to contain_exactly(@a1, @a3, @a4)
      end
    end

    context 'when searching by distance' do
      context 'given min distance' do
        it 'returns 2' do
          res = described_class.call({ distance_min: 9 })
          expect(res).to contain_exactly(@a3, @a4)
        end
      end
      context 'given max distance' do
        it 'returns 2' do
          res = described_class.call({ distance_max: 5.01 })
          expect(res).to contain_exactly(@a1, @a2)
        end
      end
      context 'given both min and max distance' do
        it 'returns 3' do
          res = described_class.call({ distance_min: 5, distance_max: 9.9 })
          expect(res).to contain_exactly(@a1, @a2, @a4)
        end
        it 'returns none' do
          res = described_class.call({ distance_min: 10, distance_max: 1 })
          expect(res).to be_empty
        end
      end
    end

    context 'when searching by duration' do
      it 'given min duration' do
        res = described_class.call({ duration_min: 2 })
        expect(res).to contain_exactly(@a2, @a3)
      end
      it 'given max duration' do
        res = described_class.call({ duration_max: 2 })
        expect(res).to contain_exactly(@a1, @a2)
      end
      it 'given both min and max duration' do
        res = described_class.call({ duration_min: 1, duration_max: 5 })
        expect(res).to contain_exactly(@a1, @a2, @a3)
      end
    end

    context 'when searching by layoff' do
      it 'given min layoff' do
        res = described_class.call({ layoff_min: 0 })
        expect(res).to contain_exactly(@a2, @a3, @a4)
      end
      it 'given max layoff' do
        res = described_class.call({ layoff_max: 1 })
        expect(res).to contain_exactly(@a2, @a3)
      end
      it 'given both min and max layoff' do
        res = described_class.call({ layoff_min: 0, layoff_max: 1 })
        expect(res).to contain_exactly(@a2, @a3)
      end
    end

    context 'when searching by mile pace' do
      it 'returns 3' do
        res = described_class.call({ mile_pace: 100 })
        expect(res).to contain_exactly(@a1, @a2, @a4)
      end
    end
  end
end
