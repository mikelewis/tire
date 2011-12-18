require 'em-synchrony'
require "em-synchrony/em-http"

module Tire
  module HTTP
    module Client
      class EMHttpRequest
        %w{get post put delete head}.each do |type|
          class_eval <<-STR
            def self.#{type}(url, data=nil)
              opts = {}
              if data
                opts[:body] = data
              end
              r = EventMachine::HttpRequest.new(url).#{type}(opts)
              Response.new r.response, r.response_header.status
            end
          STR
        end
      end
    end
  end
end
