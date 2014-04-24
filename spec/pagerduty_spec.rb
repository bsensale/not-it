require "spec_helper"

module Minitest::Assertions
  def assert_match_config(yaml, client)
    client.wont_be_nil
    client.config.must_be_kind_of Hash

    client.config.keys.sort.must_equal yaml.keys.sort
    yaml.keys.each { |key|
      client.config[key].must_equal yaml[key]
    }
  end
end

NotIt::PagerDutyClient.infect_an_assertion :assert_match_config, :must_match_config

describe NotIt::PagerDutyClient do
  include Helpers

  before do
    @yaml_file = get_fixture_file(".pagerduty-api.yaml")
    @yaml = YAML.load_file(@yaml_file)
  end

  subject { NotIt::PagerDutyClient }

  describe "when it is created" do
    it "requires arguments" do
      proc { subject.new }.must_raise ArgumentError
    end
    it "fails with just a yaml file" do
      proc {subject.new(@yaml_file)}.must_raise KeyError
    end
    it "works with a yaml file and date options" do
      start_date = Date.new(2013, 10, 1)
      end_date = Date.new(2013, 10, 4)
      dates = { :start_date => start_date, :end_date => end_date }
      pduty = subject.new(@yaml_file, dates)
      pduty.must_match_config @yaml
      pduty.start_date.must_equal start_date
      pduty.end_date.must_equal end_date
    end
  end

  describe "when it is created" do
    subject { NotIt::PagerDutyClient.new(@yaml_file,
                                         {:start_date => Date.today,
                                          :end_date => Date.today + 28
                                         })}

    it "can fetch a single schedule by id" do
      VCR.use_cassette("get_one_pagerduty",
                     :decode_compressed_response => true,
                     :erb => { :start_date => subject.start_date.iso8601.sub("+", "%2B"),
                               :end_date => subject.end_date.iso8601.sub("+", "%2B"),
                               :apitoken => @yaml["apikey"],
                     }) do
        schedule = subject.get_schedule @yaml["schedules"][0]
        schedule.wont_be_empty
        schedule.size.must_equal 6
        schedule.each { |shift| shift.must_be_kind_of NotIt::OnCallShift }
      end
    end  
    it "can fetch all schedules configured" do
      VCR.use_cassette("get_all_pagerduty_schedules",
                     :decode_compressed_response => true,
                     :erb => { :start_date => subject.start_date.iso8601.sub("+", "%2B"),
                               :end_date => subject.end_date.iso8601.sub("+", "%2B"),
                               :apitoken => @yaml["apikey"],
                     }) do
        schedules = subject.get_all_schedules
        schedules.wont_be_empty
        schedules.size.must_equal 12
        schedules.each { |shift| shift.must_be_kind_of NotIt::OnCallShift }
      end
    end
  end


end
