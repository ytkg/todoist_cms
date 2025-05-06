# frozen_string_literal: true

module TodoistCMS
  class Error < StandardError; end
  class BadRequestError < Error; end
  class UnauthorizedError < Error; end
  class ForbiddenError < Error; end
  class NotFoundError < Error; end
  class ConflictError < Error; end
end
