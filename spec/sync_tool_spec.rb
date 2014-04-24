require "spec_helper"
require "yaml"

describe NotIt::SyncTool do
  include Helpers

  before do
    @google_yaml = YAML.load_file(get_fixture_file(".google-api.yaml"))
    @pagerduty_yaml = YAML.load_file(get_fixture_file(".pagerduty-api.yaml"))
  end
  

  subject {
    VCR.use_cassette("sync_tool_create") do
      NotIt::SyncTool.new(get_fixture_file(".google-api.yaml"), get_fixture_file(".pagerduty-api.yaml"))
    end
  }

  describe "when it is created" do
    it "is not null" do
      subject.wont_be_nil
    end
    it "has defined pagerduty" do
      subject.pagerduty.wont_be_nil
    end
    it "has defined google" do
      subject.google.wont_be_nil
    end
  end

  describe "when it is created with a start date" do
    it "has the correct start and end date" do
      start_date = DateTime.new(2011, 1, 4, 9, 0, 0, "-4")
      sync = VCR.use_cassette("sync_tool_create") do
        NotIt::SyncTool.new(get_fixture_file(".google-api.yaml"),
                            get_fixture_file(".pagerduty-api.yaml"),
                            :start_date => start_date)
      end
      sync.wont_be_nil
      sync.pagerduty.wont_be_nil
      sync.google.wont_be_nil
      sync.start_date.must_equal start_date
      sync.end_date.must_equal start_date + 28
    end 
  end
  describe "when it is created with a start date and end date" do
    it "has the correct start and end date" do
      start_date = DateTime.new(2011, 1, 5, 9, 0, 0, "-4")
      end_date = DateTime.new(2011, 1, 7, 9, 0, 0, "-4")
      sync = VCR.use_cassette("sync_tool_create") do
        NotIt::SyncTool.new(get_fixture_file(".google-api.yaml"),
                            get_fixture_file(".pagerduty-api.yaml"),
                            :start_date => start_date, :end_date => end_date)
      end
      sync.wont_be_nil
      sync.pagerduty.wont_be_nil
      sync.google.wont_be_nil
      sync.start_date.must_equal start_date
      sync.end_date.must_equal end_date
    end 
  end

  describe "when asked to compare Google and PagerDuty" do
    before do
      @common_shift = NotIt::OnCallShift.new(:username =>"Common User",
                                     :email => "commonuser@example.com",
                                     :start_date => "2013-10-15",
                                     :end_date => "2013-10-24",
                                     :schedule_id => "CommonId",
                                     :schedule_name => "Common Schedule")
      @pagerduty_shift = NotIt::OnCallShift.new(:username =>"PagerDuty User",
                                     :email => "pagerdutyuser@example.com",
                                     :start_date => "2013-10-15",
                                     :end_date => "2013-10-24",
                                     :schedule_id => "PagerDutyId",
                                     :schedule_name => "PagerDuty Schedule")
      @google_shift = NotIt::OnCallShift.new(:username =>"Google User",
                                     :email => "googleuser@example.com",
                                     :start_date => "2013-10-15",
                                     :end_date => "2013-10-24",
                                     :schedule_id => "GoogleId",
                                     :schedule_name => "Google Schedule")
      @google_shifts = [@common_shift.clone, @google_shift.clone]
      @pagerduty_shifts = [@common_shift.clone, @pagerduty_shift.clone]
    end
    
    it "identifies events to remove from Google" do
      items = subject.get_events_to_remove(:gcal_shifts => @google_shifts,
                                           :pagerduty_shifts => @pagerduty_shifts)
      items.wont_be_nil
      items.size.must_equal 1
      items[0].must_be :eql?, @google_shift
    end
    it "identifies events to add to Google" do
      items = subject.get_events_to_add(:gcal_shifts => @google_shifts,
                                        :pagerduty_shifts => @pagerduty_shifts)
      items.wont_be_nil
      items.size.must_equal 1
      items[0].must_be :eql?, @pagerduty_shift
    end
  end

  describe "When it is asked to sync" do
    before do
      @add_shift = NotIt::OnCallShift.new(:username =>"Add User",
                                     :email => "adduser@example.com",
                                     :gcal_id => "gcalid",
                                     :start_date => "2013-10-15",
                                     :end_date => "2013-10-24",
                                     :schedule_id => "AddId",
                                     :schedule_name => "Add Schedule")
      @remove_shift = NotIt::OnCallShift.new(:username =>"Remove User",
                                     :gcal_id => "gcalid",
                                     :email => "removeuser@example.com",
                                     :start_date => "2013-10-15",
                                     :end_date => "2013-10-24",
                                     :schedule_id => "RemoveId",
                                     :schedule_name => "Remove Schedule")
      @keep_shift = NotIt::OnCallShift.new(:username =>"Keep User",
                                     :email => "keepuser@example.com",
                                     :gcal_id => "gcalid",
                                     :start_date => "2013-10-15",
                                     :end_date => "2013-10-24",
                                     :schedule_id => "keepid",
                                     :schedule_name => "Keep Schedule")
      subject.pagerduty.config["schedules"] = [@add_shift.schedule_id,
                                               @remove_shift.schedule_id,
                                               @keep_shift.schedule_id]
    end
    describe "when called with no gcal events" do
      before do
        subject.google.expects(:get_gcal_events).returns([])
      end
      it "does nothing when called with no pagerduty events" do
        subject.pagerduty.expects(:get_all_schedules).returns([])
        subject.google.expects(:create_gcal_event).never
        subject.google.expects(:remove_gcal_event).never
        subject.sync
      end
      it "tries to add an event when pagerduty has one" do
        subject.pagerduty.expects(:get_all_schedules).returns([@add_shift])
        subject.google.expects(:create_gcal_event).with(@add_shift)
        subject.google.expects(:remove_gcal_event).never
        subject.sync
      end
    end
    describe "when called with existing gcal events" do
      before do
        subject.google.expects(:get_gcal_events).returns([@keep_shift, @remove_shift])
      end
      it "removes all gcal events when called with no pagerduty events" do
        subject.pagerduty.expects(:get_all_schedules).returns([])
        subject.google.expects(:create_gcal_event).never
        subject.google.expects(:remove_gcal_event).with(@keep_shift)
        subject.google.expects(:remove_gcal_event).with(@remove_shift)
        subject.sync
      end
      it "tries to remove one when pagerduty has only one of them" do
        subject.pagerduty.expects(:get_all_schedules).returns([@keep_shift])
        subject.google.expects(:create_gcal_event).never
        subject.google.expects(:remove_gcal_event).with(@remove_shift)
        subject.sync
      end
      it "does nothing when pagerduty matches" do
        subject.pagerduty.expects(:get_all_schedules).returns([@keep_shift, @remove_shift])
        subject.google.expects(:create_gcal_event).never
        subject.google.expects(:remove_gcal_event).never
        subject.sync
      end
      it "tries to add one if pagerduty has an extra" do
        subject.pagerduty.expects(:get_all_schedules).returns([@keep_shift, @remove_shift, @add_shift])
        subject.google.expects(:create_gcal_event).with(@add_shift)
        subject.google.expects(:remove_gcal_event).never
        subject.sync
      end
      it "can both add and remove if needed" do
        subject.pagerduty.expects(:get_all_schedules).returns([@keep_shift, @add_shift])
        subject.google.expects(:create_gcal_event).with(@add_shift)
        subject.google.expects(:remove_gcal_event).with(@remove_shift)
        subject.sync
      end
    end
    describe "if you set :dryrun=true" do
      it "does not actually attempt to sync" do
        subject.google.expects(:get_gcal_events).returns([@keep_shift, @remove_shift])
        subject.pagerduty.expects(:get_all_schedules).returns([@keep_shift, @add_shift])
        subject.google.expects(:create_gcal_event).never
        subject.google.expects(:remove_gcal_event).never
        subject.sync(:dryrun => true)
      end
    end
  end
end
