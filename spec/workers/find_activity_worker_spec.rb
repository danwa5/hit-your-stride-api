require 'rails_helper'

RSpec.describe FindActivityWorker do
  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when strava api request returns failure' do
      it 'raises exception' do
        res = double('', success?: false, code: 401, to_s: 'exception message')
        expect(Api::Strava).to receive(:get_activities_list).and_return(res)

        expect {
          subject.perform
        }.to raise_exception(RuntimeError, '401: exception message')
      end
    end

    context 'when strava api request returns success' do
      it 'creates UserActivity' do
        expected = [
          { 'type' => 'Run', 'id' => '100' },
          { 'type' => 'Hike', 'id' => '101' },
          { 'type' => 'run', 'id' => '102' }
        ]
        stub_request(:get, %r{https://www.strava.com/api/v3/athlete/activities\?after=\d+})
          .to_return(status: 200, body: expected.to_json)

        expect(UserActivity.count).to eq(0)

        res = subject.perform

        a1 = UserActivity.first
        a2 = UserActivity.last

        aggregate_failures 'user activity attributes' do
          expect(UserActivity.count).to eq(2)
          expect(a1.activity_type).to eq('run')
          expect(a1.uid).to eq('100')
          expect(a2.activity_type).to eq('run')
          expect(a2.uid).to eq('102')
        end
      end
    end
  end

  describe '#options' do
    context 'when @date is empty' do
      example do
        expect(subject.send(:options)).to eq({ date: 1.week.ago.strftime('%Y-%m-%d') })
      end
    end
    context 'when @date is invalid' do
      example do
        subject.instance_variable_set(:@date, 'abc')
        expect(subject.send(:options)).to eq({ date: 1.week.ago.strftime('%Y-%m-%d') })
      end
    end
    context 'when @date is valid' do
      example do
        subject.instance_variable_set(:@date, '2019-08-04')
        expect(subject.send(:options)).to eq({ date: '2019-08-04' })
      end
    end
  end
end
