require 'rails_helper'

RSpec.describe CreateUserActivity do
  subject { described_class.new(uid: nil, raw_data: nil) }

  it { is_expected.to be_kind_of(Services::BaseService) }

  describe '.call' do
    before do
      @uid = '12345678'
      @raw_data = {
        "type" => "Run",
        "id" => @uid.to_i,
        "distance" => 10064.20,
        "moving_time" => 2813,
        "elapsed_time" => 1001,
        "start_date" => "2019-08-01T02:03:04Z",
        "start_date_local" => "2019-07-31T20:21:22Z",
        "start_latitude" => 37.77,
        "start_longitude" => -122.43
      }
      @geocoded = double(Geocoder::Result, data: {
        'address' => {
          'city' => 'San Francisco',
          'state' => 'California',
          'country' => 'United States'
        }
      })
    end

    context 'when activity has been processed' do
      before do
        create(:user_activity, :processed, uid: @uid, city: 'Portland')
      end
      it 'does not update UserActivity' do
        expect(UserActivity.count).to eq(1)
        expect(Geocoder).not_to receive(:search)

        res = described_class.call(uid: @uid, raw_data: @raw_data)

        activity = UserActivity.last

        expect(res).to be_success
        expect(UserActivity.count).to eq(1)
        expect(activity.city).to eq('Portland')
        expect(activity.state).to eq('processed')
      end
    end

    context 'when activity already exists but has not processed' do
      before do
        create(:user_activity, uid: @uid, city: 'Oakland')
      end
      it 'updates UserActivity' do
        expect(UserActivity.count).to eq(1)

        expect(Geocoder).to receive(:search)
          .with([@raw_data['start_latitude'], @raw_data['start_longitude']])
          .and_return([@geocoded])

        res = described_class.call(uid: @uid, raw_data: @raw_data)

        activity = UserActivity.last

        expect(res).to be_success
        expect(UserActivity.count).to eq(1)
        expect(activity.city).to eq('San Francisco')
        expect(activity.state).to eq('processed')
      end
    end

    context 'when activity already exists and raw_data arg is blank' do
      before do
        create(:user_activity, uid: @uid, city: 'Seattle', raw_data: @raw_data)
      end
      it 'updates UserActivity' do
        expect(UserActivity.count).to eq(1)

        expect(Geocoder).to receive(:search)
          .with([@raw_data['start_latitude'], @raw_data['start_longitude']])
          .and_return([@geocoded])

        res = described_class.call(uid: @uid, raw_data: nil)

        activity = UserActivity.find_by(uid: @uid)

        expect(res).to be_success
        expect(UserActivity.count).to eq(1)
        expect(activity.city).to eq('San Francisco')
        expect(activity.state).to eq('processed')
      end
    end

    context 'when activity processing fails' do
      it 'marks UserActivity as failure' do
        expect(Geocoder).to receive(:search)
          .with([@raw_data['start_latitude'], @raw_data['start_longitude']])
          .and_return([@geocoded])

        allow_any_instance_of(UserActivity).to receive(:update!).and_raise

        res = described_class.call(uid: @uid, raw_data: @raw_data)

        activity = UserActivity.last

        expect(UserActivity.count).to eq(1)
        expect(activity.state).to eq('failure')
      end
    end

    context 'when geocoder returns failure' do
      it 'does not set city, state, or country' do
        allow(Geocoder).to receive(:search).and_raise

        res = described_class.call(uid: @uid, raw_data: @raw_data)

        activity = UserActivity.last

        expect(res).to be_success
        expect(UserActivity.count).to eq(1)

        aggregate_failures 'activity attributes' do
          expect(activity.city).to be_nil
          expect(activity.state_province).to be_nil
          expect(activity.country).to be_nil
          expect(activity.state).to eq('processed')
        end
      end
    end

    it 'creates UserActivity' do
      expect(UserActivity.count).to eq(0)

      expect(Geocoder).to receive(:search)
        .with([@raw_data['start_latitude'], @raw_data['start_longitude']])
        .and_return([@geocoded])

      res = described_class.call(uid: @uid, raw_data: @raw_data)

      activity = UserActivity.last

      expect(res).to be_success
      expect(UserActivity.count).to eq(1)

      aggregate_failures 'activity attributes' do
        expect(activity.uid).to eq(@uid)
        expect(activity.activity_type).to eq('run')
        expect(activity.distance).to eq(10064.20)
        expect(activity.moving_time).to eq(2813)
        expect(activity.mile_pace).to eq(450) # 7 min, 30 sec
        expect(activity.elapsed_time).to eq(1001)
        expect(activity.city).to eq('San Francisco')
        expect(activity.state_province).to eq('CA')
        expect(activity.country).to eq('United States')
        expect(activity.start_date_utc).to eq('2019-08-01T02:03:04')
        expect(activity.start_date_local).to eq('2019-07-31T20:21:22')
        expect(activity.raw_data).to eq(@raw_data)
        expect(activity.state).to eq('processed')
      end
    end
  end

  describe '#state_province' do
    context 'when state is "NY"' do
      it 'returns "NY"' do
        allow(subject).to receive(:location).and_return({ 'state' => 'NY' })
        expect(subject.send(:state_province)).to eq('NY')
      end
    end
    context 'when state is "New York"' do
      it 'returns "NY"' do
        allow(subject).to receive(:location).and_return({ 'state' => 'New York' })
        expect(subject.send(:state_province)).to eq('NY')
      end
    end
    context 'when state is "NEW YORK"' do
      it 'returns "NEW YORK"' do
        allow(subject).to receive(:location).and_return({ 'state' => 'NEW YORK' })
        expect(subject.send(:state_province)).to eq('NEW YORK')
      end
    end
  end

  describe '#country' do
    context 'when country is "United States"' do
      it 'returns "United States"' do
        allow(subject).to receive(:location).and_return({ 'country' => 'United States' })
        expect(subject.send(:country)).to eq('United States')
      end
    end
    context 'when country is "USA"' do
      it 'returns "United States"' do
        allow(subject).to receive(:location).and_return({ 'country' => 'USA' })
        expect(subject.send(:country)).to eq('United States')
      end
    end
    context 'when country is "United States of America"' do
      it 'returns "United States"' do
        allow(subject).to receive(:location).and_return({ 'country' => 'United States of America' })
        expect(subject.send(:country)).to eq('United States')
      end
    end
  end
end
