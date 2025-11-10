# Change: Add Collapsible Calendar View

## Why
The calendar view currently takes up most of the screen space, making it difficult to see and scroll through tasks below it. Users need to scroll past a large calendar widget every time they want to review tasks, which creates a poor user experience when the primary focus is task list interaction. A collapsible/shrinkable calendar would allow users to maximize screen real estate for task viewing while keeping the calendar accessible when needed.

## What Changes
- Convert calendar screen to use a scrollable layout with collapsible calendar header
- Implement scroll-based animation that shrinks the calendar when scrolling down
- Provide drag-to-expand gesture to restore full calendar size when needed
- Maintain calendar state (selected date, focused month) during collapse/expand transitions
- Add smooth animations for calendar size transitions
- Ensure task list remains fully scrollable and accessible

## Impact
- Affected specs: **calendar-view** (existing capability - modification)
- Affected code:
  - Modified: `lib/screens/calendar_screen.dart` (replace Column with CustomScrollView/SliverAppBar pattern)
  - No new dependencies required (use existing Flutter slivers)
- No breaking changes to data models or APIs
- Improves UX for existing calendar functionality
- No impact on other screens or features
