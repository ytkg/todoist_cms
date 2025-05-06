# frozen_string_literal: true

require_relative 'item'
require_relative 'requestable'

module TodoistCMS
  class Project
    class << self
      include Requestable

      def all
        projects = request.get('/rest/v2/projects')

        projects.map do |project|
          new(id: project[:id], name: project[:name])
        end
      end

      def find(id)
        project = request.get("/rest/v2/projects/#{id}")

        new(id: project[:id], name: project[:name])
      end

      def create(name)
        raise ConflictError, "\"#{name}\" already exists." if project_name_already_exists?(name)

        project = request.post('/rest/v2/projects', { name: name })

        new(id: project[:id], name: project[:name])
      end

      def delete(id)
        request.delete("/rest/v2/projects/#{id}")
      end

      private

      def project_name_already_exists?(name)
        all.map(&:name).include?(name)
      end
    end

    attr_reader :id, :name

    def initialize(id:, name:)
      @id = id
      @name = name
    end

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    def delete
      self.class.delete(id)
    end

    def items
      Item.all(id)
    end

    def create_item(name)
      Item.create(id, name)
    end

    def truncate
      Item.truncate(id)
    end
  end
end
