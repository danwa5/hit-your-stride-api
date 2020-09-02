require 'rails_helper'

RSpec.describe IdentifyRouteWorker do
  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    let!(:activity) do
      create(:user_activity,
              uid: '123',
              distance: 101.11,
              start_latlng: '1.11,2.22',
              end_latlng: '3.33,4.44',
              city: 'San Francisco',
              state_province: 'CA',
              country: 'USA')
    end

    context 'when activity is not found' do
      it { expect(subject.perform('foobar')).to be_nil }
    end

    context 'when there are no existing routes similar in distance' do
      it 'creates a route' do
        expect {
          subject.perform('123')
        }.to change(Route, :count).by(1)

        activity.reload
        route = Route.last

        expect(activity.route).to eq(route)

        aggregate_failures 'route attributes' do
          expect(route.distance).to eq(100)
          expect(route.start_latlng).to eq(activity.start_latlng)
          expect(route.end_latlng).to eq(activity.end_latlng)
          expect(route.city).to eq(activity.city)
          expect(route.state_province).to eq(activity.state_province)
          expect(route.country).to eq(activity.country)
        end
      end
    end

    context 'when there is an existing route similar in distance but coordinates are not within proximity' do
      before do
        create(:route, distance: 102)
        allow(Geocoder::Calculations).to receive(:distance_between).and_return(0.4)
      end
      it 'creates a route' do
        expect {
          subject.perform('123')
        }.to change(Route, :count).by(1)

        activity.reload

        expect(activity.route).to eq(Route.last)
      end
    end

    context 'when there is an existing route similar in distance and coordinates are within proximity' do
      before do
        @route = create(:route, distance: 102)
        allow(Geocoder::Calculations).to receive(:distance_between).and_return(0.3)
      end
      it 'matches activity with route' do
        expect(RouteRankWorker).to receive(:perform_async).with(@route.id).once

        expect {
          subject.perform('123')
        }.not_to change(Route, :count)

        activity.reload

        expect(activity.route).to eq(@route)
      end
    end
  end
end
