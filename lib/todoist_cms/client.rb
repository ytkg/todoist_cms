# frozen_string_literal: true

require_relative 'project'

module TodoistCMS
  class Client
    class << self
      attr_accessor :token
    end

    def initialize(token)
      self.class.token = token
    end

    def projects
      Project.all
    end

    def project(id)
      Project.find(id)
    end

    def create_project(name)
      Project.create(name)
    end
  end
end
