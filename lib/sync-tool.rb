require "date"

module NotIt

  class SyncTool
    attr_accessor :google, :pagerduty
    attr_reader   :gcal_id, :service, :start_date, :end_date
    
    def initialize(google_yaml, pagerduty_yaml, options = {})
      options[:start_date] ||= DateTime.iso8601(Date.today.iso8601)
      options[:end_date] ||= options[:start_date] + 28
      @start_date = DateTime.iso8601(options[:start_date].iso8601).to_time.utc.to_datetime
      @end_date = DateTime.iso8601(options[:end_date].iso8601).to_time.utc.to_datetime
      raise ArgumentError.new "end_date cannot be before start_date" if start_date > end_date
      @google = NotIt::GoogleClient.new(google_yaml, {:start_date => @start_date, :end_date => @end_date})
      @pagerduty = NotIt::PagerDutyClient.new(pagerduty_yaml, {:start_date => @start_date, :end_date => @end_date})
    end

    def sync(options={})
      dryrun = options[:dryrun]
      pagerduty_shifts = @pagerduty.get_all_schedules
      gcal_shifts = @google.get_gcal_events @pagerduty.config["schedules"]
      
      puts "PDuty events #{pagerduty_shifts.size}: #{pagerduty_shifts}" if dryrun
      puts "GCal events #{gcal_shifts.size}: #{gcal_shifts}" if dryrun
      
      events_to_add = get_events_to_add(:gcal_shifts => gcal_shifts, :pagerduty_shifts => pagerduty_shifts) 
      events_to_add.each { |event| @google.create_gcal_event event } unless dryrun
      puts "Added #{events_to_add.size}"
      puts "#{events_to_add}" if dryrun
 
      events_to_remove = get_events_to_remove(:gcal_shifts => gcal_shifts, :pagerduty_shifts => pagerduty_shifts)
      events_to_remove.each { |event| @google.remove_gcal_event event } unless dryrun
      puts "Remove #{events_to_remove.size}"
      puts "#{events_to_remove}" if dryrun
    end

    def get_events_to_remove(options = {})
      gcal = options.fetch(:gcal_shifts)
      pagerduty = options.fetch(:pagerduty_shifts)

      results = prune_duplicates(gcal, pagerduty)
    end  
    def get_events_to_add(options = {})
      gcal = options.fetch(:gcal_shifts)
      pagerduty = options.fetch(:pagerduty_shifts)

      results = prune_duplicates(pagerduty, gcal)
    end

    def prune_duplicates(array_to_prune, test_array)
      result = array_to_prune.clone
      result.delete_if { |item|
        test_array.include? item
      }
    end
  end
end
