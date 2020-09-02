require 'rails_helper'

RSpec.describe RouteRankWorker do
  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    before do
      @route = create(:route)
    end

    context 'when route has only 1 activity' do
      before do
        @run = create(:user_activity, route: @route, mile_pace: 100, route_rank: nil)
      end

      example do
        subject.perform(@route.id)
        @run.reload
        expect(@run.route_rank).to be_nil
      end
    end

    context 'when route has multiple activities ' do
      before do
        @run1 = create(:user_activity, route: @route, mile_pace: 100, route_rank: nil)
        @run2 = create(:user_activity, route: @route, mile_pace: 200, route_rank: nil)
        @run3 = create(:user_activity, route: @route, mile_pace: 200, route_rank: nil)
        @run4 = create(:user_activity, route: @route, mile_pace: 300, route_rank: nil)
      end

      example do
        subject.perform(@route.id)

        @run1.reload
        @run2.reload
        @run3.reload
        @run4.reload

        aggregate_failures 'route rankings' do
          expect(@run1.route_rank).to eq(1)
          expect(@run2.route_rank).to eq(2)
          expect(@run3.route_rank).to eq(2)
          expect(@run4.route_rank).to eq(4)
        end
      end
    end
  end
end
