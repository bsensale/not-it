require "google/api_client"
require "yaml"

module NotIt
  class GoogleClient
    attr_reader :google, :service, :start_date, :end_date
    attr_accessor :config

    def initialize(yaml, options = {})
      @config = YAML.load_file(yaml)
      @start_date = DateTime.iso8601(options.fetch(:start_date).iso8601)
      @end_date = DateTime.iso8601(options.fetch(:end_date).iso8601)
      @google = Google::APIClient.new(:application_name => "Not-It-#{@config["client_id"]}")
      @google.authorization.client_id = @config["client_id"]
      @google.authorization.client_secret = @config["client_secret"]
      @google.authorization.scope = @config["scope"]
      @google.authorization.refresh_token = @config["refresh_token"]
      @google.authorization.access_token = @config["access_token"]
      @service = @google.discovered_api("calendar", "v3")
    end

    def get_gcal_events(schedule_ids)
      # Get the first page of results.
      page_token = nil
      result = @google.execute(:api_method => @service.events.list,
                               :parameters => {
                                              "calendarId" => @config["gcal_id"],
                                              "timeMin" => @start_date.iso8601,
                                              "timeMax" => @end_date.iso8601,
                                              "singleEvents" => true,
                                              "fields" => "items(attendees,description,end,id,start,summary)"
                              })
      raise result.body if result.error?
      # Create a place to store the shifts.
      shifts = []
      while true
        # Look at each event
        events = result.data.items
        events.each do |e|
          description = e.description
          # Skip Events that have description text different from the PagerDuty schedule ID
          next if schedule_ids.index(description).nil?
          # Parse the event
          shift = OnCallShift.from_google e
          shifts.push shift
        end
        #Get the next page
        page_token = result.data.next_page_token
        break unless page_token
        result = client.execute(:api_method => service.events.list,
                          :parameters => {"calendarId" => "primary",
                                          "pageToken" => page_token})
      end
      shifts
    end

    def create_gcal_event(shift)
      event = {
        "summary" => shift.schedule_name + ": " + shift.username,
        "description" => shift.schedule_id,
        "transparency" => "transparent",
        "start" => {
          "dateTime" => shift.start_date.iso8601
        },
        "end" => {
          "dateTime" => shift.end_date.iso8601
        },
        "attendees" => [
          {
            "email" => shift.email,
            "responseStatus" => "accepted"
          }
        ]
     }
     result = @google.execute(:api_method => @service.events.insert,
                              :parameters => { "calendarId" => @config["gcal_id"],
                                               "sendNotifications" => @config["send_notifications"]==true },
                              :body => JSON.dump(event),
                              :headers => {"Content-Type" => "application/json"})
     raise result.body if result.error?
    end
    def remove_gcal_event(shift)
      result = @google.execute(:api_method => @service.events.delete,
                      :parameters => { "calendarId" => @config["gcal_id"],
                                       "eventId" => shift.gcal_id,
                                       "sendNotifications" => @config["send_notifications"]==true })
      raise result.body if result.error?
    end
  end
end
