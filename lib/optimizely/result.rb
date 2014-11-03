module Optimizely
	class Result

    attr_reader :variation_id, :variation_name, :goal_id, :goal_name, :baseline_id, :visitors, :conversions, :conversion_rate,  :status, :improvement, :confidence

    def initialize(json)
      @variation_id = json['variation_id']
      @variation_name = json['variation_name']
      @goal_id = json['goal_id']
      @goal_name = json['goal_name']
      @baseline_id = json['baseline_id']
      @visitors = json['visitors']
      @conversions = json['conversions']
      @conversion_rate = json['conversion_rate']
      @status = json['status']
      @improvement = json['improvement']
      @confidence = json['confidence']
    end

	end
end
