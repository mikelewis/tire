require 'test_helper'
require 'tire/http/clients/curb'
require 'tire/http/clients/em-http-request'

module Tire
  module HTTP

    class ClientTest < Test::Unit::TestCase

      context "RestClient" do

        should "be default" do
          assert_equal Client::RestClient, Configuration.client
        end

        should "respond to HTTP methods" do
          assert_respond_to Client::RestClient, :get
          assert_respond_to Client::RestClient, :post
          assert_respond_to Client::RestClient, :put
          assert_respond_to Client::RestClient, :delete
          assert_respond_to Client::RestClient, :head
        end

        should "not rescue generic exceptions" do
          Client::RestClient.expects(:get).raises(RuntimeError, "Something bad happened in YOUR code")
          assert_raise(RuntimeError) do
            Client::RestClient.get 'http://example.com'
          end
        end

      end

      context "Curb" do
        setup do
          Configuration.client Client::Curb
        end

        teardown do
          Configuration.client Client::RestClient
        end

        should "use POST method if request body passed" do
          ::Curl::Easy.any_instance.expects(:http_post)

          response = Configuration.client.get "http://localhost:3000", '{ "query_string" : { "query" : "apple" }}'
        end

        should "use GET method if request body is nil" do
          ::Curl::Easy.any_instance.expects(:http_get)

          response = Configuration.client.get "http://localhost:9200/articles/article/1"
        end

      end

      context "EM Http Request" do
        setup do
          Configuration.client Client::EMHttpRequest
        end

        teardown do
          Configuration.client Client::RestClient
        end


        should "respond to HTTP methods" do
          assert_respond_to Client::EMHttpRequest, :get
          assert_respond_to Client::EMHttpRequest, :post
          assert_respond_to Client::EMHttpRequest, :put
          assert_respond_to Client::EMHttpRequest, :delete
          assert_respond_to Client::EMHttpRequest, :head
        end

        should "use POST method if request body passed" do
          response = nil

          EM.synchrony do
            response = Configuration.client.post "http://localhost:3000", '{ "query_string" : { "query" : "apple" }}'
            EM.stop
          end
          assert_equal response.class, Response
        end

        should "use GET method if request body is nil" do
          response = nil
          EM.synchrony do
            response = Configuration.client.get "http://localhost:9200/articles/article/1"
            EM.stop
          end
          assert_equal response.class, Response
        end

      end


    end
  end

end
