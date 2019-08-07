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
        "distance" => 1234.5,
        "moving_time" => 1000,
        "elapsed_time" => 1001,
        "start_date" => "2019-08-01T02:03:04Z",
        "start_date_local" => "2019-07-31T20:21:22Z",
        "location_city" => "San Francisco",
        "location_state" => "California",
        "location_country" => "United States"
      }
    end

    context 'when activity already exists but has not processed' do
      before do
        create(:user_activity, uid: @uid, city: 'Oakland')
      end
      it 'updates UserActivity' do
        expect(UserActivity.count).to eq(1)

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

        res = described_class.call(uid: @uid, raw_data: nil)

        activity = UserActivity.find_by(uid: @uid)

        expect(res).to be_success
        expect(UserActivity.count).to eq(1)
        expect(activity.city).to eq('San Francisco')
        expect(activity.state).to eq('processed')
      end
    end

    context 'when activity has been processed' do
      before do
        create(:user_activity, :processed, uid: @uid, city: 'Portland')
      end
      it 'does not update UserActivity' do
        expect(UserActivity.count).to eq(1)

        res = described_class.call(uid: @uid, raw_data: @raw_data)

        activity = UserActivity.last

        expect(res).to be_success
        expect(UserActivity.count).to eq(1)
        expect(activity.city).to eq('Portland')
        expect(activity.state).to eq('processed')
      end
    end

    context 'when activity processing fails' do
      it 'marks UserActivity as failure' do
        allow_any_instance_of(UserActivity).to receive(:update!).and_raise

        res = described_class.call(uid: @uid, raw_data: @raw_data)

        activity = UserActivity.last

        expect(UserActivity.count).to eq(1)
        expect(activity.state).to eq('failure')
      end
    end

    it 'creates UserActivity' do
      expect(UserActivity.count).to eq(0)

      res = described_class.call(uid: @uid, raw_data: @raw_data)

      activity = UserActivity.last

      expect(res).to be_success
      expect(UserActivity.count).to eq(1)

      aggregate_failures 'activity attributes' do
        expect(activity.uid).to eq(@uid)
        expect(activity.activity_type).to eq('run')
        expect(activity.distance).to eq(1234.5)
        expect(activity.moving_time).to eq(1000)
        expect(activity.elapsed_time).to eq(1001)
        expect(activity.city).to eq('San Francisco')
        expect(activity.state_province).to eq('California')
        expect(activity.country).to eq('United States')
        expect(activity.start_date_utc).to eq('2019-08-01T02:03:04')
        expect(activity.start_date_local).to eq('2019-07-31T20:21:22')
        expect(activity.raw_data).to eq(@raw_data)
        expect(activity.state).to eq('processed')
      end
    end
  end
end
