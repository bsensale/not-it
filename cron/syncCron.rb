require 'date'
require 'not-it'

@day_of_week = ARGV[0].to_i
@time_of_day = ARGV[1].to_i
weeks_to_sync = ARGV[2].to_i
weeks_to_sync ||= 4
days_to_sync = 7 * weeks_to_sync
dry_run = !(ARGV[3]=='true')
puts dry_run

# Function to calculate when the next shift change is.
def next_shift_change
  # What day is today?
  date = Date.today
  day = date.wday
  # If today matches the day of the shift change, next change is in a week.
  if day == @day_of_week
    date + 7
  # If we're earlier in the week, find the gap...
  elsif day < @day_of_week
    date + (@day_of_week-day)
  # otherwise, find the other end
  else
    date + (7-(day-@day_of_week))
  end
end

# Calculates the Changeover date in UTC, hopefully accounting for daylight savings. :-/
def get_utc_change(next_change_date)
  next_change_time = Time.new(next_change_date.year, next_change_date.month, next_change_date.day, @time_of_day, 0, 0)
  next_change_time.utc
  DateTime.parse(next_change_time.to_s)
end

# Find out the DateTime objects for the week we are syncing.
next_change = next_shift_change
start_date = get_utc_change(next_change)
current_start = get_utc_change(start_date-7)
sync_end = get_utc_change(start_date + days_to_sync)

# Sync current week
sync = NotIt::SyncTool.new('.google-api.yaml', ".pagerduty-api-#{@time_of_day}.yaml", :start_date => current_start, :end_date => start_date)
sync.sync :dryrun => dry_run
sync = NotIt::SyncTool.new('.google-api.yaml', ".pagerduty-api-#{@time_of_day}.yaml", :start_date => start_date, :end_date => sync_end)
sync.sync :dryrun => dry_run


