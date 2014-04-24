module NotIt
  class PagerDutyClient
    attr_reader :start_date, :end_date
    attr_accessor :config

    def initialize(yaml, options = {})
      @config = YAML.load_file(yaml)
      @start_date = DateTime.iso8601(options.fetch(:start_date).iso8601)
      @end_date = DateTime.iso8601(options.fetch(:end_date).iso8601)
    end

    def get_all_schedules
      pagerduty_shifts = []
      @config["schedules"].each { |schedule| pagerduty_shifts.concat get_schedule(schedule) }
      pagerduty_shifts
    end

    def get_schedule(id)
      schedule = get_details id
      id = schedule["schedule"]["id"]
      name = schedule["schedule"]["name"]
      entries = schedule["schedule"]["final_schedule"]["rendered_schedule_entries"]
      shifts = []
      entries.each do |entry|
        shifts.push OnCallShift.from_pagerduty(id, name, entry)
      end
      shifts
    end
    def get_details(schedule)
      uri = URI.parse("https://#{@config['subdomain']}.pagerduty.com/api/v1/schedules/#{schedule}")
      query = "since=" + URI.encode_www_form_component(@start_date.iso8601)
      query += "&until=" + URI.encode_www_form_component(@end_date.iso8601)
      uri.query = query
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = http.get(uri.to_s, {
        "Content-type" => "application/json",
        "Authorization" => "Token token=#{@config['apikey']}"
      })
      case res
      when Net::HTTPSuccess
        JSON.parse(res.body)
      else res.error!
      end
    end
  end
end
