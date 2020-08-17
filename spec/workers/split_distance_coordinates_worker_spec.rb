require 'rails_helper'

RSpec.describe SplitDistanceCoordinatesWorker do
  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when activity is not found' do
      it { expect(subject.perform('foobar')).to be_nil }
    end

    context 'when activity is found' do
      before do
        allow(FastPolylines).to receive(:decode).and_return([[1.1,1.2], [2.1,2.2], [3.1,3.2], [4.1,4.2], [5.1,5.2]])
        allow(Geocoder::Calculations).to receive(:distance_between).and_return(0.5)
      end
      example do
        activity = create(:user_activity, uid: '123', split_distance_coordinates: nil)

        expect(IdentifyRouteWorker).to receive(:perform_async).with('123').once

        res = subject.perform('123')
        activity.reload

        expect(activity.split_distance_coordinates).to eq(res)

        expect(res).to eq({
          'coordinates' => [
            { 'distance' => 1.0, 'latlng' => [3.1, 3.2] },
            { 'distance' => 2.0, 'latlng' => [5.1, 5.2] }
          ]
        })
      end
    end
  end
end
