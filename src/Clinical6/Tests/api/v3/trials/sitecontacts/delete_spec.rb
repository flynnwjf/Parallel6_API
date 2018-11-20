require_relative '../../../../../../../src/spec_helper'

describe 'Delete V3/trials/site_contacts/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "trials_sitecontacts_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:firstname) {(0...8).map{ ('a'..'z').to_a[rand(26)] }.join}
  let(:lastname) {(0...8).map{ ('a'..'z').to_a[rand(26)] }.join}
  let(:create_firstname) {(0...8).map{ ('a'..'z').to_a[rand(26)] }.join}
  let(:create_lastname) {(0...8).map{ ('a'..'z').to_a[rand(26)] }.join}
  let(:create_contact_email){"test@abctest123.com"}
  let(:create_site_id){"2"}
  let(:create_type){"trials__site"}
#Requests
  let(:token) { V3::Users::Session::Create.new(user_email, user_password, base_url).token }
  let(:id) { V3::Trials::SiteContacts::Create.new(token, user_email, base_url, create_type, create_firstname, create_lastname, create_contact_email, create_site_id).id }
  let(:trials_sitecontacts_delete) { V3::Trials::SiteContacts::Delete.new(token, user_email, base_url, id) }

  context 'with valid user' do
    it 'returns 200 and deletes site contacts' do
      expect(trials_sitecontacts_delete.response.code).to eq 204
    end
  end

  context 'with invalid id' do
    let(:id) {test_data["invalid_id"]}
    it 'returns 404 error & Record Not Found message' do
      expect(trials_sitecontacts_delete.response.code).to eq 404
      expect(trials_sitecontacts_delete.response.body).to match /Record Not Found/
    end
  end

end

