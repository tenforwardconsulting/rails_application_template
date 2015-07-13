module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  def add_authentication_headers(client)
    headers.merge!({
      'X-Habit-Catalyst-Token' => client.authentication_token
    })
  end

  # Custom methods so headers (used for authentication and specifying api version)
  # are always sent
  def post(path, request_params = {})
    super path, request_params, headers
  end

  def get(path, request_params = {})
    super path, request_params, headers
  end

  def headers
    @headers ||= {
      'HTTP_ACCEPT' => "application/vnd.habitcatalyst.v#{version}"
    }
  end

  def version
    @version ||= begin
      default_version = 1
      matches = /\/api\/v(\d+)/.match @example.metadata[:file_path]
      matches.try(:[], 1) || default_version
    end
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request

  # At the very least parses current spec file path
  # for api version in request specs
  config.before :each do |example|
    @example = example
  end
end
