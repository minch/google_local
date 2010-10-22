module GoogleLocal
  
  # A search sent to Google Local Search RESTful API
  class Search
    include HTTParty
    
    base_uri "http://ajax.googleapis.com/ajax/services/search"
    default_params :v => '1.0'
    
    # Central location for the local search
    attr_accessor :center_location
    
    # Google Search API Key
    attr_accessor :api_key
    
    # The latitude and longitude of the central location
    attr_accessor :latlng
    
    def initialize(center_location = nil, api_key=nil)
      @api_key = api_key
      if center_location
        @latlng = GoogleLocal::Geocode.find_latlng(center_location) # Parse center_location into latitude and longitude
      end
    end
    
    # Perform a Google Local search given a query.
    def find(query,options={})
      options.merge!(:q => query, :sll => @latlng) # Merge in the query and the lat/lng into the options
      fetch_locations(self.class.get("/local", :query => options)) # Make the get request
    end
    
    # Perform a Google Local search given a query (w/out a lat/lng requirement)
    def find_local(query, options={})
      query = encode_query(query)
      options.merge!(:q => query)

      response = self.class.get("/local", :query => options)
      locations(response)
    end

    private
    
    def fetch_locations(response)
      response['responseData']['results'].flatten.collect {|r| Mash.new(r) }
    end
    
    def locations(response)
      response['responseData']['results']
    end

    def encode_query(query)
      query.gsub(/ /, '+')
    end
  end
end
