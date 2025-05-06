# frozen_string_literal: true

require 'faraday'
require_relative 'errors/error'

module TodoistCMS
  class Request
    BASE_URL = 'https://api.todoist.com/'

    ERROR_MAP = {
      400 => BadRequestError,
      401 => UnauthorizedError,
      403 => ForbiddenError,
      404 => NotFoundError
    }.freeze

    def initialize(token)
      @token = token
    end

    def get(endpoint, params = {})
      response = connection.get(endpoint, params)

      error(response) unless response.success?

      response.body
    end

    def post(endpoint, params = {})
      response = connection.post(endpoint, params)

      error(response) unless response.success?

      response.body
    end

    def delete(endpoint)
      response = connection.delete(endpoint)

      error(response) unless response.success?

      nil
    end

    private

    def connection
      Faraday.new(url: BASE_URL) do |f|
        f.request :authorization, :Bearer, @token
        f.request :json
        f.response :json, parser_options: { symbolize_names: true }
        f.adapter Faraday.default_adapter
      end
    end

    def error(response)
      raise ERROR_MAP[response.status]&.new(response.body) || "#{response.status}: #{response.body}"
    end
  end
end
