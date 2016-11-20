require 'google/apis/admin_directory_v1'
require 'google/apis/people_v1'
require 'google/api_client/client_secrets.rb'

class GhostUserCreator
  # Alias the modules
  ADMIN_DIRECTORY_API = Google::Apis::AdminDirectoryV1
  PEOPLE_API = Google::Apis::PeopleV1
  NAME_AND_EMAIL = "person.names,person.emailAddresses"

  def self.start_with_google_token(access_token, current_user)
    unless get_company_domain(current_user).casecmp("gmail.com") == 0
      Company.find_or_create_by(domain:get_company_domain(current_user).downcase)
      process_directory_contacts(access_token, get_company_domain(current_user), current_user)
    end

    #process_personal_contacts(access_token, current_user)
  end

  #TODO we are only importing the first 500 contacts (update if needed)
  def self.process_directory_contacts(access_token, domain, current_user)
    directory_api_call = ADMIN_DIRECTORY_API::DirectoryService.new
    directory_api_call.authorization = AccessToken.new(access_token["credentials"]["token"])
    response = directory_api_call.list_users(domain: domain, view_type: "domain_public", max_results: 30)
    if response.users
      import_users_from_directory(response.users, current_user)
    end
  end

  # def self.process_personal_contacts(access_token, current_user)
  #   contacts_api_call = PEOPLE_API::PeopleService.new
  #   contacts_api_call.authorization = AccessToken.new(access_token["credentials"]["token"])
  #   response = contacts_api_call
  #                  .list_person_connections("people/me", request_mask_include_field: NAME_AND_EMAIL)
  #   if response.connections
  #     import_users_from_contacts(response.connections, current_user)
  #   end
  # end

  def self.import_users_from_directory(external_user_contacts, current_user)
    company = Company.find_by_domain(get_company_domain(current_user).downcase)
    external_user_contacts.each do | external_user_info |
      User.find_or_create_by(email: external_user_info.primary_email.downcase) do |user|
        create_ghost_user_from_directory(external_user_info, user, company)
      end
      current_user.company = company
    end
  end

  # def self.import_users_from_contacts(external_user_contacts, current_user)
  #   external_user_contacts.each do | external_user_info |
  #     if external_user_info.email_addresses
  #       primary_email_obj = external_user_info.email_addresses.select { | email | email.metadata.primary } .first
  #       user_contact = User.find_or_create_by(email: primary_email_obj.value.downcase) do |new_user_obj|
  #         create_ghost_user_from_contacts(external_user_info, new_user_obj)
  #       end
  #       current_user.follow(user_contact)
  #     end
  #   end
  # end

  def self.create_ghost_user_from_directory(new_user_info, new_user_object, company)
    if new_user_info.name
      new_user_object.first_name = new_user_info.name.given_name
      new_user_object.last_name = new_user_info.name.family_name
    end
    new_user_object.is_ghost_user = true
    new_user_object.skip_confirmation!
    new_user_object.company = company
    new_user_object.password = Devise.friendly_token[0,20]
    new_user_object.save!
  end

  # def self.create_ghost_user_from_contacts(new_user_info, new_user_object)
  #   if new_user_info.names
  #     new_user_objec
  # t.first_name = new_user_info.names.first.given_name
  #     new_user_object.last_name = new_user_info.names.first.family_name
  #   end
  #   new_user_object.is_ghost_user = true
  #   new_user_object.password = Devise.friendly_token[0,20]
  #   new_user_object.save!
  # end

  def self.get_company_domain(current_user)
    return current_user.email.split("@").last
  end


  class AccessToken
    attr_reader :token
    def initialize(token)
      @token = token
    end

    def apply!(headers)
      headers['Authorization'] = "Bearer #{@token}"
    end
  end
end
