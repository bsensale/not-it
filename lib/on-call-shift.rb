require "date"

module NotIt
  class OnCallShift
    attr_reader :schedule_name, :email, :start_date, :end_date, :schedule_id, :username, :gcal_id

    def initialize(options = {})
      #Optional parameters
      @gcal_id = options[:gcal_id]

      #Required parameters
      @schedule_name = options.fetch(:schedule_name)
      @schedule_id = options.fetch(:schedule_id)
      @username = options.fetch(:username)
      @email = options.fetch(:email)
      @start_date = DateTime.parse(options.fetch(:start_date))
      @end_date = DateTime.parse(options.fetch(:end_date))
      raise ArgumentError.new "Start Date must be not be later than end date" if @start_date > @end_date
    end

    def self.from_google(event)
      gcal_id = event.id
      schedule_id = event.description
      username = event.attendees[0].displayName
      email = event.attendees[0].email
      if event.start.date.nil? then
        start_date = event.start.dateTime.iso8601
      else
        start_date = event.start.date
      end
      if event.end.date.nil? then
        end_date = event.end.dateTime.iso8601
      else
        end_date = event.end.date
      end
      name = event.summary.split(":")[0].strip
      self.new(:schedule_name => name,
               :schedule_id => schedule_id,
               :gcal_id => gcal_id,
               :username => username, 
               :email => email,
               :start_date => start_date,
               :end_date => end_date)
    end
    
    def self.from_pagerduty(schedule_id, schedule_name, event)
      self.new(:schedule_id => schedule_id,
               :schedule_name => schedule_name,
               :username => event["user"]["name"],
               :email => event["user"]["email"],
               :start_date => event["start"],
               :end_date => event["end"]
               )
    end

    def eql?(shift)
      self.class.equal?(shift.class) &&
        @schedule_id == shift.schedule_id &&
        @email == shift.email &&
        @start_date == shift.start_date &&
        @end_date == shift.end_date
    end
    
    def ==(shift)
        self.eql? shift
    end

    def hash
      str = @schedule_id + @schedule_name + @email + @start_date.iso8601 + @end_date.iso8601
      str.hash
    end
  end
end
