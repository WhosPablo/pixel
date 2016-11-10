require 'google/apis/admin_directory_v1'
require 'google/apis/people_v1'
require 'google/api_client/client_secrets.rb'

# TODO spin a thread to do this
class GhostUserCreator
  # Alias the modules
  ADMIN_DIRECTORY_API = Google::Apis::AdminDirectoryV1
  PEOPLE_API = Google::Apis::PeopleV1
  NAME_AND_EMAIL = "person.names,person.emailAddresses"

  def self.start_with_google_token(access_token, user)
    #TODO both of these only take in the first page of users (does not account for others)
    unless get_company_domain(user).casecmp("gmail.com")
      process_directory_contacts(access_token, get_company_domain(user))
    end
    process_personal_contacts(access_token)
  end

  def self.process_directory_contacts(access_token, domain)
    directory_api_call = ADMIN_DIRECTORY_API::DirectoryService.new
    directory_api_call.authorization = AccessToken.new(access_token.credentials.token)
    response = directory_api_call.list_users(domain: domain, view_type: "domain_public" )
    import_users_from_directory(response.users)
  end

  def self.process_personal_contacts(access_token)
    contacts_api_call = PEOPLE_API::PeopleService.new
    contacts_api_call.authorization = AccessToken.new(access_token.credentials.token)
    response = contacts_api_call
                   .list_person_connections("people/me", request_mask_include_field: NAME_AND_EMAIL)
    import_users_from_contacts(response.connections)
  end

  def self.import_users_from_directory(potential_users)
    potential_users.each do | user_info |
      user = User.find_or_create_by(email: user_info.primary_email) do |user|
        user.email = user_info.primary_email
        user.password = Devise.friendly_token[0,20]
      end
      user.save!
    end
  end

  def self.import_users_from_contacts(potential_users)
    potential_users.each do | user_info |
      if user_info.email_addresses
        primary_email_obj = user_info.email_addresses.select { | email | email.metadata.primary } .first
        user = User.find_or_create_by(email: primary_email_obj.value) do |user|
          user.email = primary_email_obj.value
          user.password = Devise.friendly_token[0,20]
        end
        user.save!
      end
    end
  end

  def self.get_company_domain(user)
    return user["email"].split("@").last
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
