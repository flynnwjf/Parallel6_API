require_relative '../../../../../../src/spec_helper'

describe 'Delete V3/languages/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "language_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { test_data["name"]}
  let(:iso){(0...2).map { ('a'..'z').to_a[rand(26)] }.join }
  let(:language_create) { V3::Languages::Create.new(token, user_email, base_url, name, iso) }
  let(:id) { language_create.id }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:language_delete) { V3::Languages::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 204 status code & deletes the languages' do
      expect(language_delete.response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & Record Not Found message in body' do
      expect(language_delete.response.code).to eq 404
      expect(language_delete.response.body).to match /Record Not Found/
    end
  end

end



