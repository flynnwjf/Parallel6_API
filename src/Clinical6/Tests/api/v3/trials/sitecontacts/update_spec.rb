require_relative '../../../../../../../src/spec_helper'

describe 'Put V3/trials/site_contacts/:id' do
#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "trials_sitecontacts_update" }
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

  let(:trials_sitecontacts_create_id) { V3::Trials::SiteContacts::Create.new(token, user_email, base_url, create_type, create_firstname, create_lastname, create_contact_email, create_site_id).id }
  let(:update) { V3::Trials::SiteContacts::Update.new(token, user_email, base_url, trials_sitecontacts_create_id, firstname, lastname) }

  context 'with valid user' do
    it 'returns 200 and update site contacts' do
      expect(update.response.code).to eq 200
      expect(update.firstname).to match firstname
      expect(update.lastname).to match lastname
    end
  end

  context 'with invalid user' do
    let(:trials_sitecontacts_create_id) {test_data["invalid_id"]}
    it 'returns 404 error & record not found message' do
      expect(update.response.code).to eq 404
      expect(update.response.body).to match /Record Not Found/
    end
  end

end

