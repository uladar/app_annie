require 'faraday'
require 'json'
require 'app_annie/error_response'
require 'app_annie/account'
require 'app_annie/product'
require 'app_annie/intelligence'
require 'app_annie/meta_data'
require 'app_annie/version'

module AppAnnie
  API_ROOT = '/v1.2/accounts'.freeze

  class << self

    attr_writer :api_key

    def api_key
      @api_key || ENV['APPANNIE_API_KEY']
    end

  end

  def self.accounts(options = {})
    response = connection.get do |req|
      req.headers['Authorization'] = "Bearer #{api_key}"
      req.headers['Accept'] = 'application/json'
      req.url API_ROOT, options
    end

    if response.status == 200
      JSON.parse(response.body)['accounts'].map { |hash| Account.new(hash) }
    else
      ErrorResponse.raise_for(response)
    end
  end

  def self.connection
    @connection ||= Faraday.new url: 'https://api.appannie.com' do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  def self.authorized_get(path, params = {})
    response = connection.get do |req|
      req.headers["Authorization"] = "Bearer #{api_key}"
      req.headers["Accept"] = "application/json"
      req.url(path)
      req.params = params
    end

    if response.status == 200
      JSON.parse(response.body)
    else
      ErrorResponse.raise_for(response)
    end
  end

  class Unauthorized < Exception; end
  class RateLimitExceeded < Exception; end
  class ServerError < Exception; end
  class ServerUnavailable < Exception; end
  class BadResponse < Exception; end

end
