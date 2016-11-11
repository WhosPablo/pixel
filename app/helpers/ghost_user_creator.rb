require 'google/apis/admin_directory_v1'
require 'google/apis/people_v1'
require 'google/api_client/client_secrets.rb'

# TODO spin a thread to do this
class GhostUserCreator
  # Alias the modules
  ADMIN_DIRECTORY_API = Google::Apis::AdminDirectoryV1
  PEOPLE_API = Google::Apis::PeopleV1
  NAME_AND_EMAIL = "person.names,person.emailAddresses"

  def self.start_with_google_token(access_token, current_user)
    #TODO both of these only take in the first page of users (does not account for others)
    unless get_company_domain(current_user).casecmp("gmail.com") == 0
      process_directory_contacts(access_token, get_company_domain(user), current_user)
    end
    process_personal_contacts(access_token, current_user)
  end

  def self.process_directory_contacts(access_token, domain, current_user)
    directory_api_call = ADMIN_DIRECTORY_API::DirectoryService.new
    directory_api_call.authorization = AccessToken.new(access_token.credentials.token)
    response = directory_api_call.list_users(domain: domain, view_type: "domain_public" )
    if response.users
      import_users_from_directory(response.users, current_user)
    end
  end

  def self.process_personal_contacts(access_token, current_user)
    contacts_api_call = PEOPLE_API::PeopleService.new
    contacts_api_call.authorization = AccessToken.new(access_token.credentials.token)
    response = contacts_api_call
                   .list_person_connections("people/me", request_mask_include_field: NAME_AND_EMAIL)
    if response.connections
      import_users_from_contacts(response.connections, current_user)
    end
  end

  def self.import_users_from_directory(potential_users, current_user)
    potential_users.each do | user_info |
      user = User.find_or_create_by(email: user_info.primary_email.downcase) do |user|
        if user_info.name
          user.first_name = user_info.name.given_name
          user.last_name = user_info.name.family_name
        end
        user.email = user_info.primary_email
        user.password = Devise.friendly_token[0,20]
        user.save!
      end
      current_user.follow(user)
    end
  end

  def self.import_users_from_contacts(potential_users, current_user)
    potential_users.each do | user_info |
      if user_info.email_addresses
        primary_email_obj = user_info.email_addresses.select { | email | email.metadata.primary } .first
        user = User.find_or_create_by(email: primary_email_obj.value.downcase) do |user|
          if user_info.names
            user.first_name = user_info.names.first.given_name
            user.last_name = user_info.names.first.family_name
          end
          user.password = Devise.friendly_token[0,20]
          user.save!
        end
        current_user.follow(user)
      end
    end
  end

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
