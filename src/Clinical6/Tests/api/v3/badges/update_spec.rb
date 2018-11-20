require_relative '../../../../../../src/spec_helper'

describe 'Patch V3/badges/:id/update' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "badges_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_title) { pre_test_data["title"] }
  let(:pre_description) { pre_test_data["description"] }
#Test Info
  let(:testname) { "badges_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:title) { test_data["title"] }
  let(:description) { test_data["description"] }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:badges_create) { V3::Badges::Create.new(token, user_email, base_url, pre_type, pre_title, pre_description)}
  let(:id) { badges_create.id }
  let(:badges_update) { V3::Badges::Update.new(token, user_email, base_url, id, type, title, description) }

  context 'with valid user and valid title' do
    it 'returns 200 status code & updates a badge' do
      expect(badges_create.response.code).to eq 201
      expect(badges_update.response.code).to eq 200
      expect(JSON.parse(badges_update.response).dig('data','id')).to eq id
      expect(JSON.parse(badges_update.response).dig('data','type')).to eq type
      expect(JSON.parse(badges_update.response).dig('data', 'attributes',"title")).to eq title
      expect(JSON.parse(badges_update.response).dig('data', 'attributes',"description")).to eq description
      puts "response_body: " + badges_update.response.body.to_s
      #cleanup
      expect(V3::Badges::Delete.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid title' do
    let(:title) { test_data["invalid_title"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(badges_create.response.code).to eq 201
      expect(badges_update.response.code).to eq 422
      expect(badges_update.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Badges::Delete.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:badges_update) { V3::Badges::Update.new(token, invalid_user, base_url, id, type, title, description) }
    it 'returns 401 error' do
      expect(badges_create.response.code).to eq 201
      expect(badges_update.response.code).to eq 401
      expect(badges_update.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Badges::Delete.new(token, user_email, base_url, id).response.code).to eq 204
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid badge id' do
    let(:id) { test_data["invalid_id"] }
    it 'returns 404 error & record not found message in body' do
      expect(badges_update.response.code).to eq 404
      expect(badges_update.response.body).to match /Record Not Found/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



