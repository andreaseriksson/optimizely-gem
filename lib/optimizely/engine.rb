module Optimizely
	class Engine

		BASE_URL = "https://www.optimizelyapis.com/experiment/v1/"

		attr_accessor :url

		# Initialize Optimizely using an API token.
		#
		# == Options:
		# +:api_token+:: Use an API token you received before.
		# +:timeout+::   Set Net:HTTP timeout in seconds (default is 300).
		#
		def initialize(options={})
			@options = options
	  	check_init_auth_requirements
		end

		# Initalize the Token so it can be used in every request we'll do later on.
		# Besides that also set the authentication header.
	  def token=(token)
      @token = token
      set_headers
    end

    # Returns the list of projects available to the authenticated user.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  projects = optimizely.projects # Look up all projects.
    #
		def projects
			if @projects.nil?
				response = self.get("projects")
				@projects = response.collect { |project_json| Project.new(project_json) }
			end
			@projects
		end

    # Returns the details for a specific project.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  project = optimizely.project(12345) # Look up the project.
    #
		def project(id)
			@url = "projects/#{id}"
			raise OptimizelyError::NoProjectID, "A Project ID is required to retrieve the project." if id.nil?

			if @project.nil?
				response = self.get(@url)
				@project = Project.new(response)
			end
			@project
		end

    # Returns the list of experiments for a specified project.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  experiments = optimizely.experiments(12345) # Look up all experiments for a project.
    #
		def experiments(project_id)
			raise OptimizelyError::NoProjectID, "A Project ID is required to retrieve experiments." if project_id.nil?

			if @experiments.nil?
				response = self.get("projects/#{project_id}/experiments")
				@experiments = response.collect { |response_json| Experiment.new(response_json) }
			end
			@experiments
		end

    # Returns the details for a specific experiment.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  experiment = optimizely.experiment(12345) # Look up the experiment.
    #
		def experiment(id)
			@url = "experiments/#{id}"
			raise OptimizelyError::NoExperimentID, "An Experiment ID is required to retrieve the experiment." if id.nil?

			if @experiment.nil?
				response = self.get(@url)
				@experiment = Experiment.new(response)
			end
			@experiment
		end

    # Returns the details for a specific experiment.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  experiment = optimizely.results(12345) # Look up the experiment results.
    #
		def results(id)
			@url = "experiments/#{id}/results"
			raise OptimizelyError::NoExperimentID, "An Experiment ID is required to retrieve the experiment." if id.nil?

      if @results.nil?
				response = self.get(@url)
        @results = response.collect { |response_json| Result.new(response_json) }
			end
			@results
		end

    # Returns the list of variations for a specified experiment.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  variations = optimizely.variations(12345) # Look up all variations for an experiment.
    #
		def variations(experiment_id)
			raise OptimizelyError::NoExperimentID, "An Experiment ID is required to retrieve variations." if experiment_id.nil?

			if @variations.nil?
				response = self.get("projects/#{experiment_id}/variations")
				@variations = response.collect { |variation_json| Variation.new(variation_json) }
			end
			@variations
		end

    # Returns the details for a specific variation.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  variation = optimizely.variation(12345) # Look up the variation.
    #
		def variation(id)
			@url = "variations/#{id}"
			raise OptimizelyError::NoVariationID, "A Variation ID is required to retrieve the variation." if id.nil?

			if @variation.nil?
				response = self.get(@url)
				@variation = Variation.new(response)
			end
			@variation
		end

    # Returns the list of audiences for a specified project.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  audiences = optimizely.audiences(12345) # Look up all audiences for a project.
    #
		def audiences(project_id)
			raise OptimizelyError::NoProjectID, "A Project ID is required to retrieve audiences." if project_id.nil?

			if @audiences.nil?
				response = self.get("projects/#{project_id}/audiences")
				@audiences = response.collect { |audience_json| Audience.new(audience_json) }
			end
			@audiences
		end

    # Returns the details for a specific audience.
    #
    # == Usage
    #  optimizely = Optimizely.new({ api_token: 'oauth2_token' })
    #  audience = optimizely.audience(12345) # Look up the audience.
    #
		def audience(id)
			@url = "audiences/#{id}"
			raise OptimizelyError::NoAudienceID, "An Audience ID is required to retrieve the audience." if id.nil?

			if @audience.nil?
				response = self.get(@url)
				@audience = Audience.new(response)
			end
			@audience
		end

		# Return the parsed JSON data for a request that is done to the Optimizely REST API.
	  def get(url)
	  	uri 		 = URI.parse("#{BASE_URL}#{url}")
	  	https    = Net::HTTP.new(uri.host, uri.port)
	  	https.read_timeout = @options[:timeout] if @options[:timeout]
	  	https.verify_mode = OpenSSL::SSL::VERIFY_NONE
	    https.use_ssl = true
	    request  = Net::HTTP::Get.new(uri.request_uri, @headers)
	    response = https.request(request)

	    # Response code error checking
      if response.code != '200'
        check_response(response.code, response.body)
      else
		  	parse_json(response.body)
		  end
	  end

	  def post
	  	uri 		 = URI.parse("#{BASE_URL}#{url}/")
	  	https    = Net::HTTP.new(uri.host, uri.port)
	  	https.read_timeout = @options[:timeout] if @options[:timeout]
	  	https.verify_mode = OpenSSL::SSL::VERIFY_NONE
	    https.use_ssl = true
	    request  = Net::HTTP::Post.new(uri.request_uri, @headers)
	    response = https.request(request)

	    # Response code error checking
      check_response(response.code, response.body) if response.code != '201'
	  end

	  def put
	  	uri 		 = URI.parse("#{BASE_URL}#{url}/")
	  	https    = Net::HTTP.new(uri.host, uri.port)
	  	https.read_timeout = @options[:timeout] if @options[:timeout]
	  	https.verify_mode = OpenSSL::SSL::VERIFY_NONE
	    https.use_ssl = true
	    request  = Net::HTTP::Put.new(uri.request_uri, @headers)
	    response = https.request(request)

	    # Response code error checking
      check_response(response.code, response.body) if response.code != '202'
	  end

	  def delete
	  	raise OptimizelyError::NoId, "An ID is required to delete data." if @url.nil?

	  	uri 		 = URI.parse("#{BASE_URL}#{@url}")
	  	https    = Net::HTTP.new(uri.host, uri.port)
	  	https.read_timeout = @options[:timeout] if @options[:timeout]
	  	https.verify_mode = OpenSSL::SSL::VERIFY_NONE
	    https.use_ssl = true
	    request  = Net::HTTP::Delete.new(uri.request_uri, @headers)
	    response = https.request(request)

	    # Response code error checking
      check_response(response.code, response.body) if response.code != '204'
	  end

	  def check_response(code, body)
	  	case code
      when '400'
        raise OptimizelyError::BadRequest, body + "Your request was not sent in valid JSON. (status code: #{code})."
      when '401'
        raise OptimizelyError::Unauthorized, "Your API token was missing or included in the body rather than the header (status code: #{code})."
      when '403'
        raise OptimizelyError::Forbidden, body + "You provided an API token but it was invalid or revoked, or if you don't have read/ write access to the entity you're trying to view/edit (status code: #{code})."
      when '404'
      	raise OptimizelyError::NotFound, body + "The id used in the request was inaccurate or you didn't have permission to view/edit it (status code: #{code})."
      else
        raise OptimizelyError::UnknownError, body + " (status code: #{code})."
      end
	  end


	  private


		# If there is no API token or an empty API token raise an exception.
	  def check_init_auth_requirements
	  	if @options[:api_token].nil? || @options[:api_token].empty?
		    raise OptimizelyError::NoAPIToken, "An API token is required to initialize Optimizely."
		  else
		  	self.token = @options[:api_token]
		  end
	  end

	  # As the authentication for the Optimizely Experiments API is handled via the
	  # Token header in every request we set the header + also make clear we expect JSON.
	  def set_headers
	  	@headers = {}
	  	@headers['Token'] = @token
	  	@headers['Content-Type'] = "application/json"
	  end

	  # Parse the JSON data that's been requested through the get method.
	  def parse_json(data)
	  	json = JSON.parse(data)
	  	json
	  end
	end
end
