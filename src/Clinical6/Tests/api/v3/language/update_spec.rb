require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/languages/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "language_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { test_data["name"] }
  let(:update_name) { test_data["update_name"] }
  let(:iso){(0...2).map { ('a'..'z').to_a[rand(26)] }.join }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::Languages::Create.new(token, user_email, base_url, name, iso).id }
  let(:language_update) { V3::Languages::Update.new(token, user_email, base_url, id, update_name) }

  context 'with valid user' do
    it 'returns 200 status code & updates a language' do
      expect(language_update.response.code).to eq 200
      expect(JSON.parse(language_update.response).dig('data','id')).to eq id
      expect(JSON.parse(language_update.response).dig('data', 'type')).to eq "languages"
      expect(JSON.parse(language_update.response).dig('data', 'attributes', 'name')).to eq update_name
      #Clean Up
      expect(V3::Languages::Delete.new(token, user_email, base_url, id).response.code).to eq 204
    end
  end

  context 'with valid user and invalid name' do
    let(:id) { V3::Languages::Index.new(token, user_email, base_url).id }
    let(:update_name) { test_data["invalid_name"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(language_update.response.code).to eq 422
      expect(language_update.response.body).to match /can\'t be blank/
    end
  end

  context 'with invalid user' do
    let(:id) { test_data["id"] }
    let(:env_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    it 'returns 401 error' do
      expect(language_update.response.code).to eql 401
      expect(language_update.response.body).to match /Authentication Failed/
    end
  end

end



