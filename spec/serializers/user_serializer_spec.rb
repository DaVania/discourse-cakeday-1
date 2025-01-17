# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSerializer do
  let(:user) { Fabricate(:user, date_of_birth: "2017-04-05") }
  let!(:admin) { Fabricate(:admin) }

  context "when user is logged in" do
    let(:serializer) { described_class.new(user, scope: Guardian.new(user), root: false) }

    it "should include both the user's birthdate and cakedate" do
      expect(serializer.as_json[:birthdate]).to eq(user.date_of_birth)
      expect(serializer.as_json[:cakedate]).to eq(user.created_at.strftime("%Y-%m-%d"))
    end

    it "should not include the user's cakedate when cakeday_enabled is false" do
      SiteSetting.cakeday_enabled = false
      expect(serializer.as_json.has_key?(:cakedate)).to eq(false)
    end

    it "should not include the user's birthdate when cakeday_birthday_enabled is false" do
      SiteSetting.cakeday_birthday_enabled = false
      expect(serializer.as_json.has_key?(:birthdate)).to eq(false)
    end
  end

  context 'when admin is logged in' do
    let(:serializer) { described_class.new(user, scope: Guardian.new(admin), root: false) }

    it "should include the user's date of birth" do
      expect(serializer.as_json[:date_of_birth]).to eq(user.date_of_birth)
    end

    it "should not include the user's date of birth when cakeday_birthday_enabled is false" do
      SiteSetting.cakeday_birthday_enabled = false

      expect(serializer.as_json[:date_of_birth]).to eq(nil)
    end
  end

  context "when user is not logged in" do
    let(:serializer) { described_class.new(user, scope: Guardian.new, root: false) }

    it "should not include the user's birthdate nor the cakedate" do
      expect(serializer.as_json.has_key?(:birthdate)).to eq(false)
      expect(serializer.as_json.has_key?(:cakedate)).to eq(false)
    end
  end
end
