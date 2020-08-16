require 'rails_helper'

RSpec.describe Route, type: :model do
  describe 'relationships' do
    it { is_expected.to have_many(:user_activities) }
  end
end
