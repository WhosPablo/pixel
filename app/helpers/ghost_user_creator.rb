require 'google/apis/admin_directory_v1'
require 'google/api_client/client_secrets.rb'


class GhostUserCreator
  ADMIN_API = Google::Apis::AdminDirectoryV1 # Alias the module

  def self.process_users(potential_users)
    potential_users.each do | user_info |
      user = User.find_or_create_by(email: user_info.primary_email)
      user.update(email: user_info.primary_email)
    end
  end

  def self.process_new_token(access_token, user)
    # Request users
    user_service = ADMIN_API::DirectoryService.new

    user_service.authorization = AccessToken.new(access_token.credentials.token)

    response = user_service.list_users(domain: get_company_domain(user), view_type: "domain_public" )
    process_users(response.users)
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
