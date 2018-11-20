require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/mobile_users/invitation/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "mobileuser_invitations_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:email) { "TestEmail" + DateTime.now.strftime('+%Q').to_s + "@mailinator.com"}
  let(:member_type) { test_data["member_type"] }
  let(:first_name) { "FirstName" + Time.new.strftime("%Y%m%d") }
  let(:last_name) { "LastName" + Time.new.strftime("%Y%m%d") }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:invitations_create) { V3::MobileUser::Invitations::Create.new(token, user_email, base_url, email, member_type, first_name, last_name) }

  context 'with valid user and valid email' do
    it 'returns 200 status code & sends an email invitation' do
      expect(invitations_create.response.code).to eq 200
      expect(JSON.parse(invitations_create.response).dig('data','type')).to eq "mobile_users"
      expect(JSON.parse(invitations_create.response).dig('data', 'attributes',"email")).to eq email
      puts "invitation_create_response_body: "+ invitations_create.response.to_s
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with valid user and invalid email' do
    let(:invalid_email) { test_data["invalid_email"] }
    it 'returns 422 error & can\'t be blank message in body' do
      expect(invitations_create.response.code).to eq 422
      expect(invitations_create.response.body).to match /can\'t be blank/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:invalid_user) { test_data["invalid_name"] }
    let(:invitations_create) { V3::MobileUser::Invitations::Create.new(token, invalid_user, base_url, email, member_type, first_name, last_name) }
    it 'returns 401 error' do
      expect(invitations_create.response.code).to eq 401
      expect(invitations_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



