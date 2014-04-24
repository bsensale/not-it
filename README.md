not-it
======

Keeps a Shared Google Calendar in sync with one or more PagerDuty Schedules.

Installation
------------

    gem install not-it

Usage
-----

Not-It connects to your PagerDuty account via apikeys, and your Google Account
  via OAuth2.0 using a refresh token.

The main class you will work with in `NotIt::SyncTool` which uses
  `NotIt::OnCallShift`'s to track who is on call.

The constructor for `NotIt::SyncTool` takes two yaml files as arguments.  The
  first has all the information needed for Google; the second for PagerDurty.

Sample versions of these yaml files can be found in spec/fixtures as
  .google-api.yaml and .pagerduty-api.yaml

To use the tool, you run the following code:

    require 'not-it'
    sync_tool = NotIt::SyncTool(<LOCATION_OF_GOOGLE_YAML>, <LOCATION_OF_PAGERDUTY_YAML)
    sync_tool.sync

Contributing to not-it
----------------------
 
* Check out the latest master to make sure the feature hasn't been implemented
   or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it
   and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a
   future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to
   have your own version, or is otherwise necessary, that is fine, but please
   isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2013 Brian Sensale. See LICENSE.txt for further details.

