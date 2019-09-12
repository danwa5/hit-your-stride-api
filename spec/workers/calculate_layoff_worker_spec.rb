require 'rails_helper'

RSpec.describe CalculateLayoffWorker do
  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when there are no activities' do
      it 'returns false' do
        expect(subject.perform).to eq(false)
      end
    end

    context 'when there are activities' do
      before do
        @a1 = create(:user_activity, start_date_local: Date.new(2019, 9, 1))
        @a2 = create(:user_activity, start_date_local: Date.new(2019, 9, 3))
        @a3 = create(:user_activity, start_date_local: Date.new(2019, 9, 9))
      end
      it 'calculates and updates each run layoff' do
        subject.perform

        @a1.reload
        @a2.reload
        @a3.reload

        aggregate_failures 'layoff values' do
          expect(@a1.layoff).to be_nil
          expect(@a2.layoff).to eq(2)
          expect(@a3.layoff).to eq(6)
        end
      end
    end
  end
end
