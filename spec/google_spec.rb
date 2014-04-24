require "spec_helper"

module Minitest::Assertions
  def assert_match_google_config(yaml, client)
    client.wont_be_nil
    client.config.must_be_kind_of Hash
    client.google.wont_be_nil
    client.service.id.must_equal "calendar:v3"

    client.config.keys.sort.must_equal yaml.keys.sort
    yaml.keys.each { |key|
      client.config[key].must_equal yaml[key]
    }
  end
end

NotIt::GoogleClient.infect_an_assertion :assert_match_google_config, :must_match_config

describe NotIt::GoogleClient do
  include Helpers

  before do
    @yaml_file = get_fixture_file(".google-api.yaml")
    @yaml = YAML.load_file(@yaml_file)
  end
  
  subject { 
    VCR.use_cassette("sync_tool_create") { NotIt::GoogleClient.new(@yaml_file,
                                                                   {:start_date => Date.today,
                                                                    :end_date => Date.today+28
                                                                   })}
  }

  describe "when it is created" do
    subject { NotIt::GoogleClient }
    it "requires arguments" do
      proc { subject.new }.must_raise ArgumentError
    end
    it "does not work with just a yaml file" do
      proc { subject.new @yaml_file }.must_raise KeyError
    end
    it "works with a yaml file and date options" do
      start_date = Date.new(2013, 10, 1)
      end_date = Date.new(2013, 10, 4)
      dates = { :start_date => start_date, :end_date => end_date }
      google = VCR.use_cassette("sync_tool_create") { subject.new(@yaml_file, dates) }
      google.must_match_config @yaml
      google.start_date.must_equal start_date
      google.end_date.must_equal end_date
    end
  end

  describe "when asked for a Google Calendar" do
    it "returns one" do
      start_date = DateTime.iso8601(Date.today.iso8601)
      end_date = start_date + 28
      pagerduty_schedules = YAML.load_file(get_fixture_file(".pagerduty-api.yaml"))["schedules"]
      events = VCR.use_cassette("get_gcal_events",
                      :erb => { :start_date => start_date.iso8601.sub("+", "%2B"),
                                :end_date => end_date.iso8601.sub("+", "%2B"),
                                :gcal_id => @yaml["gcal_id"],
                                :client_id => @yaml["client_id"],
                                :access_token => @yaml["access_token"]
                                
                      }) do
        subject.get_gcal_events pagerduty_schedules
      end
      events.wont_be_empty
    end
  end

  describe "when asked to create an event on a Google Calendar" do
    before do
      @shift = NotIt::OnCallShift.new(:username =>"Fake User",
                                     :email => "fakeuser@example.com",
                                     :start_date => "2013-10-15",
                                     :end_date => "2013-10-24",
                                     :schedule_id => "TestSched",
                                     :schedule_name => "Test Schedule")
    end
    it "adds one" do
      VCR.use_cassette("create_gcal_event",
                      :erb => { :gcal_id => @yaml["gcal_id"],
                                :client_id => @yaml["client_id"],
                                :access_token => @yaml["access_token"],
                                :send_notifications => true
                      }) do
        subject.create_gcal_event @shift
      end
    end
    it "respects the sendNotification config option" do
      subject.config["send_notifications"] = false
      VCR.use_cassette("create_gcal_event",
                      :erb => { :gcal_id => @yaml["gcal_id"],
                                :client_id => @yaml["client_id"],
                                :access_token => @yaml["access_token"],
                                :send_notifications => false
                      }) do
        subject.create_gcal_event @shift
      end
    end
  end

  describe "when asked to remove an event from a Google Calendar" do
    it "removes one" do
      shift = NotIt::OnCallShift.new(:username =>"Fake User",
                                     :gcal_id => "EVENTID",
                                     :email => "fakeuser@example.com",
                                     :start_date => "2013-10-15",
                                     :end_date => "2013-10-24",
                                     :schedule_id => "TestSched",
                                     :schedule_name => "Test Schedule")
      VCR.use_cassette("remove_gcal_event",
                      :erb => { :gcal_id => @yaml["gcal_id"],
                                :client_id => @yaml["client_id"],
                                :access_token => @yaml["access_token"],
                                :event_id => shift.gcal_id,
                                :send_notifications => true
                      }) do
        subject.remove_gcal_event shift
      end
    end
  end
end
