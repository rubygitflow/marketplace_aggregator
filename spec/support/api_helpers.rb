# frozen_string_literal: true

module ApiHelpers
  def json_body
    JSON.parse(response.body)
  end

  def auth_header(client = nil)
    {
      HTTP_X_ACCESS_TOKEN: (client || create(:confirmed_client)).api_token
    }
  end

  def do_request(method, path, options = {})
    send method, path, options
  end
end
