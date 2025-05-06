# frozen_string_literal: true

require_relative 'request'

module TodoistCMS
  module Requestable
    private

    def request
      Request.new(Client.token)
    end
  end
end
