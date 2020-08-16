require 'rails_helper'

RSpec.describe UserActivity, type: :model do
  let(:user_activity) { create(:user_activity) }
  subject { user_activity }

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:activity_type).in_array(%w(run))}
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_uniqueness_of(:uid).case_insensitive }
  end

  describe 'relationships' do
    it { is_expected.to belong_to(:route).optional }
  end

  describe '#polyline' do
    example do
      activity = create(:user_activity, raw_data: { 'map': { 'summary_polyline': 'abc' }})
      expect(activity.polyline).to eq('abc')
    end
  end
end
