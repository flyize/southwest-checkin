require_relative './errors'

module Southwest
  class Request
    protected

    def make_request(path, params, content_type)
      Typhoeus::Request.get("#{base_uri}#{path}", {
        params: params, headers: headers(content_type)
      })
    end

    def headers(content_type)
      {
        'User-Agent' => user_agent,
        'Content-Type' => content_type,
        'X-Api-Key' => api_key,
        'Accept-Language' => 'en-US;q=1'
      }
    end

    def base_uri
      # 'https://api-extensions.southwest.com/v1/mobile'
      'https://mobile.southwest.com/api/extensions/v1/mobile'
    end

    def user_agent
      "Southwest/3.3.7 (iPhone; iOS 9.3.5; Scale/2.00)"
    end

    def api_key
      # "l7xx8d8bfce4ee874269bedc02832674129b"
      'l7xx12ebcbc825eb480faa276e7f192d98d1'
    end
  end
end
