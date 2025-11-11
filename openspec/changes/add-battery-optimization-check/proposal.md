# Proposal: Battery Optimization Check

## Problem Statement
The app uses a foreground service to run timers in the background, ensuring accurate time tracking even when the app is minimized or the screen is locked. However, Android's battery optimization settings can still interfere with the foreground service's reliability by restricting background execution or putting the app to sleep.

Users may not be aware that battery optimization is enabled for the app, leading to:
- Timers stopping or pausing unexpectedly when the app is backgrounded
- Inconsistent timer behavior across different Android devices and OS versions
- Poor user experience due to inaccurate time tracking
- Frustration from having to manually discover and disable battery optimization settings

## Proposed Solution
Add a battery optimization check screen that:
1. Detects whether battery optimization is disabled for the app
2. Shows the current status (optimized vs. not optimized) with clear visual indicators
3. Provides an explanation of why disabling optimization is important for timer accuracy
4. Offers a quick action button to open Android's battery optimization settings for the app
5. Can be accessed from the Settings screen

This will guide users to configure their device correctly for reliable background timer operation, reducing support issues and improving overall app reliability.

## Capabilities Affected
- **New Capability**: `battery-optimization-check` - Detection and management of Android battery optimization settings

## User Impact
- **Positive**: Users will be guided to configure battery settings correctly, ensuring timers work reliably in the background
- **Positive**: Reduces confusion and frustration from unexpected timer behavior
- **Positive**: Proactive notification of battery optimization issues before they cause problems
- **Risk**: Minimal - purely additive feature, no breaking changes to existing functionality

## Implementation Approach
1. Create a new `BatteryOptimizationScreen` in `lib/screens/`
2. Add native Android method channel methods to:
   - Check if battery optimization is ignored for the app
   - Open the system battery optimization settings intent
3. Update `SettingsScreen` to include a link to the battery optimization check
4. Add visual indicators (icons, colors) to show optimization status clearly
5. Include explanatory text to help users understand the importance of the setting

## Dependencies
- Requires Android API level 23 (Marshmallow) or higher for battery optimization APIs
- Uses existing method channel pattern (`com.timetracker/timer_service` or new channel)
- No new external dependencies needed

## Testing Strategy
- Manual testing on Android devices with battery optimization enabled/disabled
- Test on multiple Android OS versions (API 23+, 33+)
- Verify intent opens correct system settings page
- Verify status check accurately reflects current battery optimization state

## Related Changes
- Complements existing `add-task-notifications` and background timer implementation
- Works alongside the `TimerForegroundService` to ensure reliable background operation

## Timeline
- **Effort Estimate**: Small (1-2 days)
- **Priority**: Medium - Improves reliability but not blocking core functionality
