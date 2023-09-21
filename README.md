# Activity Timeline Lightning WebComponent

LWC implementation of https://lightningdesignsystem.com/components/activity-timeline/#site-main-content

### Key features

- Activity timeline for any object
- Can pull in all related/child objects of a parent object beyond Tasks and Events
- Configured through a custom object configuration 
- Can have multiple configurations for the same object that can be used in different app pages or by critieria
- Ability to use an Apex dataprovider for retrieving related object data
- Integrated quick action support for Log a Call, New Task, New Event and Send Email

### Using unmanaged version
When installing the unmanaged version, make sure to remove the package namespace (timeline__) from the activityTimeline.js file.
