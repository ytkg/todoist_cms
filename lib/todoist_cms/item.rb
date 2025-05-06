# frozen_string_literal: true

require_relative 'errors/error'
require_relative 'requestable'

module TodoistCMS
  class Item
    class << self
      include Requestable

      def all(project_id)
        uncompleted_items = fetch_uncompleted_items(project_id)
        completed_items = fetch_completed_items(project_id)

        uncompleted_items + completed_items
      end

      def create(project_id, name)
        raise ConflictError, "\"#{name}\" already exists." if item_name_already_exists?(project_id, name)

        item = request.post('/rest/v2/tasks', { project_id: project_id, content: name })

        new(id: item[:id], name: item[:content])
      end

      def delete(id)
        request.delete("/rest/v2/tasks/#{id}")
      end

      def truncate(project_id)
        items = fetch_uncompleted_items(project_id)

        truncate_items(items)
      end

      private

      def fetch_uncompleted_items(project_id)
        items = request.get('/rest/v2/tasks', { project_id: project_id })

        items.map do |item|
          new(id: item[:id], name: item[:content])
        end
      end

      def fetch_completed_items(project_id)
        items = request.get('/sync/v9/completed/get_all', { project_id: project_id })[:items]

        items.map do |item|
          new(id: item[:id], name: item[:content], completed_at: item[:completed_at])
        end
      end

      def truncate_items(items)
        items.each(&:delete)

        nil
      end

      def item_name_already_exists?(project_id, name)
        uncompleted_items = fetch_uncompleted_items(project_id)

        uncompleted_items.map(&:name).include?(name)
      end
    end

    attr_reader :id, :name, :completed_at

    def initialize(id:, name:, completed_at: nil)
      @id = id
      @name = name
      @completed_at = completed_at
    end

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    def delete
      self.class.delete(id)
    end
  end
end
