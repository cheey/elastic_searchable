require 'crack'
require 'rest_client'
require 'elastic_searchable/active_record'

module ElasticSearchable

  class ElasticError < StandardError; end
  class << self
    # setup the default index to use
    # one index can hold many object 'types'
    @@default_index = nil
    def default_index=(index)
      @@default_index = index
    end
    def default_index
      @@default_index || 'elastic_searchable'
    end

    #perform a request to the elasticsearch server
    def request(method, path, params = {}, options = {})
      options.reverse_merge! :content_type => :json, :accept => :json
      url = ['http://', 'localhost:9200', path].join
      RestClient.log = Logger.new(STDOUT)
      response = case method
      when :get
        RestClient.get url, params.merge(options)
      when :put
        RestClient.put url, params, options
      when :post
        RestClient.post url, params, options
      when :delete
        RestClient.delete url, params.merge(options)
      else
        raise ElasticSearchable::ElasticError("Unknown request method: #{method}")
      end
      json = Crack::JSON.parse(response.body)
      #puts "elasticsearch request: #{method} #{url} #{" finished in #{json['took']}ms" if json['took']}"
      json
    end
  end
end

ActiveRecord::Base.send(:include, ElasticSearchable::ActiveRecord)
