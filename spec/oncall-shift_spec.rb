require "spec_helper"

describe NotIt::OnCallShift do
   
  subject { NotIt::OnCallShift }

  describe "when it is created" do
    it "requires arguments" do
      proc { subject.new }.must_raise KeyError
    end
    it "requires a start date" do
      proc { subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :end_date => "10-02-2012")}.must_raise KeyError
    end
    it "requires an end date" do
      proc { subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "10-02-2012")}.must_raise KeyError
    end
    it "requires an :username" do
      proc { subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :email => "fakeuser@example.com",
                          :start_date => "10-02-2012",
                          :end_date => "10-02-2012")}.must_raise KeyError
    end
    it "requires a valid schedule_name" do
      proc { subject.new(:schedule_id => "FAKESCHEDID",
                          :email => "test@example.com",
                          :username => "Fake User",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")}.must_raise KeyError
    end
    it "requires an :email" do
      proc { subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :start_date => "10-02-2012",
                          :end_date => "10-02-2012")}.must_raise KeyError
    end
    it "requires a valid start date" do
      proc { subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "BAD",
                          :end_date => "10-02-2012")}.must_raise ArgumentError
    end
    it "requires a valid end date" do
      proc { subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "10-02-2012",
                          :end_date => "BAD")}.must_raise ArgumentError
    end
    it "requires that start date is not later than the end" do
      proc { subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "10-03-2012",
                          :end_date => "10-02-2012")}.must_raise ArgumentError
    end
    it "works" do
      shift = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "10-02-2012",
                          :end_date => "10-02-2012")
      shift.wont_be_nil
    end
    it "can take a gcal id" do
      shift = subject.new(:schedule_id => "FAKESCHEDID",
                          :gcal_id => "gcalid",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "10-02-2012",
                          :end_date => "10-02-2012")
      shift.wont_be_nil
    end
    it "can handle DateTime format" do
      shift = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift.wont_be_nil
    end
    it "has matching hashes if they are equal" do
      shift1 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :email => "test@example.com",
                          :username => "Fake User",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift2 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift1.hash.must_equal shift2.hash
    end
    it "has matching hashes regardless of gcal_id" do
      shift1 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :email => "test@example.com",
                          :username => "Fake User",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift2 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :gcal_id => "gcal_id",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift1.hash.must_equal shift2.hash
    end
    it "has differing hashes if they are different..." do
      shift1 = subject.new(:schedule_id => "FAKESCHEDIDi1",
                          :schedule_name => "Fake Schedule Name",
                          :email => "test@example.com",
                          :username => "Fake User",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift2 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :gcal_id => "gcal_id",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift1.hash.wont_equal shift2.hash
    end
    it "validates equality" do
      shift1 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :email => "test@example.com",
                          :username => "Fake User",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift2 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift1.must_be :eql?, shift2
    end
    it "validates equality regardless of gcal_id" do
      shift1 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :email => "test@example.com",
                          :username => "Fake User",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift2 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :gcal_id => "gcal_id",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "2013-10-22T16:06:25-04:00",
                          :end_date => "2013-10-29T16:06:25-04:00")
      shift1.must_be :eql?, shift2
    end
    it "does not validate equality when they are different" do
      shift1 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :username => "Fake User",
                          :email => "test@example.com",
                          :start_date => "10-02-2012",
                          :end_date => "10-02-2012")
      shift2 = subject.new(:schedule_id => "FAKESCHEDID",
                          :schedule_name => "Fake Schedule Name",
                          :email => "fakeusertwo@example.com",
                          :username => "Fake User Two",
                          :start_date => "10-02-2012",
                          :end_date => "10-02-2012")
      shift1.wont_be :eql?, shift2
    end
  end
end
