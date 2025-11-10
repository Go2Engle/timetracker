## 1. Update Calendar Screen Layout
- [x] 1.1 Replace `Scaffold` with `body: Column` with `CustomScrollView` and slivers
- [x] 1.2 Convert calendar widget to `SliverAppBar` with flexible space
- [x] 1.3 Move daily summary and task list to `SliverList` or `SliverToBoxAdapter`
- [x] 1.4 Configure `SliverAppBar` with appropriate `expandedHeight` (calendar full height ~400dp)
- [x] 1.5 Set `SliverAppBar` `collapsedHeight` for minimal calendar display (~80dp)

## 2. Implement Collapsible Calendar Widget
- [x] 2.1 Wrap `TableCalendar` in `FlexibleSpaceBar` within `SliverAppBar`
- [x] 2.2 Implement scroll-based animation using `SliverAppBar` pinned/floating properties
- [x] 2.3 Add custom `FlexibleSpaceBar` title showing selected date in collapsed state
- [x] 2.4 Configure pinned: true to keep collapsed calendar at top during scroll
- [x] 2.5 Add smooth animation curve for expand/collapse transitions

## 3. Maintain Calendar State During Transitions
- [x] 3.1 Verify selected date persists through collapse/expand cycles
- [x] 3.2 Verify focused month remains unchanged during transitions
- [x] 3.3 Test task list continues displaying correct tasks during state changes
- [x] 3.4 Ensure task markers/indicators remain visible in collapsed state (if space permits)

## 4. Visual Feedback and Polish
- [x] 4.1 Add visual cue in collapsed state (e.g., expand icon or hint text)
- [x] 4.2 Ensure smooth 200-300ms animation duration for transitions
- [x] 4.3 Test animations don't cause jank or performance issues
- [x] 4.4 Verify daily summary section remains accessible and visible
- [x] 4.5 Ensure "Go to today" button remains functional in both states

## 5. Testing and Validation
- [x] 5.1 Test scroll down collapses calendar smoothly
- [x] 5.2 Test scroll to top expands calendar smoothly
- [x] 5.3 Test drag-down gesture on collapsed calendar expands it
- [x] 5.4 Verify task list is fully scrollable when calendar is collapsed
- [x] 5.5 Test calendar navigation (prev/next month) works in expanded state
- [x] 5.6 Verify date selection works correctly in both collapsed and expanded states
- [x] 5.7 Test with varying task list lengths (empty, few items, many items)
- [x] 5.8 Test on different screen sizes and orientations
- [x] 5.9 Verify theme support (light/dark mode) for new collapsed state
- [x] 5.10 Ensure no layout jumps or visual glitches during transitions

## 6. Code Quality and Documentation
- [x] 6.1 Add code comments explaining sliver configuration
- [x] 6.2 Verify code follows Dart style guide and project conventions
- [x] 6.3 Run `dart format` on modified files
- [x] 6.4 Test on connected Android device for real-world behavior
- [x] 6.5 Update any relevant inline documentation about calendar behavior
