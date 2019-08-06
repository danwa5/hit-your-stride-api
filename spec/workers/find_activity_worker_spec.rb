require 'rails_helper'

RSpec.describe FindActivityWorker do
  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when strava api request returns failure' do
      it 'raises exception' do
        res = double('', success?: false, code: 401, to_s: 'exception message')
        expect(Api::Strava).to receive(:get_activities).and_return(res)

        expect {
          subject.perform
        }.to raise_exception(RuntimeError, '401: exception message')
      end
    end

    context 'when strava api request returns success' do
      it 'calls CreateUserActivity for each run activity' do
        expected = [
          { 'type' => 'Run', 'id' => '100' },
          { 'type' => 'Hike', 'id' => '101' },
          { 'type' => 'run', 'id' => '102' }
        ]
        stub_request(:get, %r{https://www.strava.com/api/v3/athlete/activities\?after=\d+})
          .to_return(status: 200, body: expected.to_json)

        expect(CreateUserActivity).to receive(:call)
          .with(uid: '100', raw_data: { 'type' => 'Run', 'id' => '100' })
          .and_call_original

        expect(CreateUserActivity).to receive(:call)
          .with(uid: '102', raw_data: { 'type' => 'run', 'id' => '102' })
          .and_call_original

        res = subject.perform
        expect(res).to eq(%w(100 102))
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
