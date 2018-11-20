require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/users/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "user_update_attribute" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:id) { test_data["id"] }
  let(:enabled) { false }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:update_user) { V3::Users::Update.new(token, user_email, base_url, id, enabled) }

  context 'with valid user' do
    context 'when updating user to enabled' do
      let(:enabled) { true }
      it 'returns 200 and sets disabled date to null' do
        expect(update_user.response.code).to eq 200
        expect(update_user.disabled_date).to be nil
      end
    end
    context 'when updating user to disabled' do
      let(:enabled) { false }
      it 'returns 200 and sets disabled date to a date' do
        expect(update_user.response.code).to eq 200
        d = DateTime.parse(update_user.disabled_date) rescue nil
        expect(d.class).to be DateTime
      end
    end

  end

  context 'with invalid user' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message' do
      expect(update_user.response.code).to eq 404
      expect(update_user.response.body).to match /Record Not Found/
    end
  end

end

