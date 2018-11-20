require_relative '../../../../../../../src/spec_helper'
require 'date'

describe 'Post V3/trials/site_contacts/create' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Preconditions
  let(:pre_testname) { "trials_sites_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:pre_type) { pre_test_data["type"] }
  let(:pre_name) { pre_test_data["name"] + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
#Test Info
  let(:testname) { "trials_sitecontacts_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:first_name) { test_data["first_name"] + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:last_name) { test_data["last_name"] + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:contact_email) { test_data["contact_email"] + DateTime.now.strftime("+%Q") + "@mailinator.com" }
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:trials_sitecontacts_create) { V3::Trials::SiteContacts::Create.new(token, user_email, base_url, type, first_name, last_name, contact_email, site_id) }

  context 'with valid user' do
    let(:site_id) { V3::Trials::Sites::Create.new(token, user_email, base_url, pre_type, pre_name).id}
    it 'returns 201 status code ' do
      expect(trials_sitecontacts_create.response.code).to eq 201
      expect(JSON.parse(trials_sitecontacts_create.response).dig('data', 'type')).to eq type
      expect(JSON.parse(trials_sitecontacts_create.response).dig('data', 'attributes', 'first_name')).to eq first_name
      expect(JSON.parse(trials_sitecontacts_create.response).dig('data', 'attributes', 'last_name')).to eq last_name
      expect(JSON.parse(trials_sitecontacts_create.response).dig('data', 'attributes', 'email')).to eq contact_email
      #cleanup
      expect(V3::Trials::SiteContacts::Delete.new(token, user_email, base_url, trials_sitecontacts_create.id).response.code).to eq 204
    end
  end

  context 'with invalid parameter' do
    let(:contact_email) { test_data["invalid_parameter"] }
    let(:site_id) { "1"}
    it 'returns 422 error' do
      expect(trials_sitecontacts_create.response.code).to eq 422
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with unauthorized user' do
    let(:env_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
    let(:user_email) { env_user["email"] }
    let(:user_password) { env_user["password"] }
    let(:site_id) { "1"}
    it 'returns 403 error' do
      expect(trials_sitecontacts_create.response.code).to eq 403
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

  context 'with invalid user' do
    let(:env_invalid_user) { DataHandler.get_env_user(env_info, :invalid_user) }
    let(:invalid_user) { env_invalid_user["email"] }
    let(:trials_sitecontacts_create) { V3::Trials::SiteContacts::Create.new(token, invalid_user, base_url, type, first_name, last_name, contact_email, "1") }
    it 'returns 401 error' do
      expect(trials_sitecontacts_create.response.code).to eq 401
      expect(trials_sitecontacts_create.response.body).to match /Authentication Failed/
      #cleanup
      expect(V3::Users::Session::Delete.new(token, user_email, base_url).response.code).to eq 204
    end
  end

end



