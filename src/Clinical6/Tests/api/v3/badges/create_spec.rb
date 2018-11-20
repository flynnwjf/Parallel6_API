require_relative '../../../../../../src/spec_helper'

describe 'Post V3/badges/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "badges_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] }
  let(:description) { test_data["description"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:badges_create) { V3::Badges::Create.new(token, user_email, base_url, type, title, description) }
  let(:created_id) { badges_create.id }

  context 'with valid user and valid title' do
    it 'returns 201 status code & creates a badge' do
        expect(badges_create.response.code).to eq 201
        expect(created_id.to_i).to be >=1
        expect(JSON.parse(badges_create.response).dig('data','type')).to eq type
        expect(JSON.parse(badges_create.response).dig('data', 'attributes','title')).to eq title
        expect(JSON.parse(badges_create.response).dig('data','attributes','description')).to eq description
        puts "response_body: " + badges_create.response.body.to_s
        #cleanup
        expect(V3::Badges::Delete.new(token, user_email, base_url, created_id).response.code).to eq 204
        expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid title' do
    let(:title) { test_data["invalid_title"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(badges_create.response.code).to eq 422
      expect(badges_create.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:badges_create) { V3::Badges::Create.new(token, invalid_user, base_url, type, title, description) }
    it 'returns 401 error' do
      expect(badges_create.response.code).to eq 401
      expect(badges_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



