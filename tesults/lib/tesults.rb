require 'json'
require 'uri'
require 'net/https'

module Tesults
    def self.upload(data)
        uri = URI("https://www.tesults.com/results")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req.body = data.to_json
        res = http.request(req)
        jsonData = JSON.parse(res.body)
        success = false
        message = ""
        if jsonData['error'] == nil
            success = true
            message = (jsonData['data'])['message']
        else
            success = false
            message = (jsonData['error'])['message']
        end
        val = {:success => success, :message => message}
    rescue => e
        val = {:success => false, :message => e}
    end
end
