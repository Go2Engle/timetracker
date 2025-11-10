# Tasks: Modernize UI

## Task List

### 1. Modernize Tasks Screen Layout Structure
**Description:** Convert TaskListScreen from Column-based layout to CustomScrollView with SliverList for better scroll performance and modern layout.

**Changes:**
- Replace `Column` widget with `CustomScrollView`
- Convert sections to Sliver widgets (SliverToBoxAdapter, SliverList)
- Update padding to use SliverPadding where appropriate

**Validation:**
- App compiles without errors
- Tasks screen scrolls smoothly
- All existing functionality preserved (refresh, create task, navigate to details)

**Dependencies:** None

---

### 2. Modernize Active Task Cards
**Description:** Update `_ActiveTaskCard` widget to use gradient backgrounds, refined badges, and improved visual hierarchy matching Reports screen style.

**Changes:**
- Add gradient background to card container
- Update status badge styling (Running/Paused chips)
- Refine elapsed time typography (displaySmall, bold, tabular figures)
- Add box shadow for depth
- Update icon button styling
- Improve spacing and padding

**Validation:**
- Active task cards display with gradient background
- Play/pause/stop buttons function correctly
- Status badges show correct state and colors
- Elapsed time updates in real-time

**Dependencies:** Task 1

---

### 3. Modernize Stopped Task Cards
**Description:** Update `_TaskCard` widget to match Reports screen card styling with outlined borders and refined layout.

**Changes:**
- Update Card elevation to 0 with outlined border
- Add BorderRadius.circular(16)
- Wrap elapsed time in colored container badge
- Add schedule icon to metadata
- Update ListTile to custom Padding + Column layout for better control
- Improve spacing between elements

**Validation:**
- Stopped task cards match Reports visual style
- Start button functions correctly
- Tap to navigate to detail screen works
- Cards display correctly in list

**Dependencies:** Task 1

---

### 4. Add Section Headers and Icons
**Description:** Add visual section headers with icons to separate "Active Tasks" and "Recent Tasks" sections.

**Changes:**
- Update existing Padding headers to include icon
- Style text with bold titleMedium + primary color
- Add 16px padding around headers
- Use `Icons.play_circle` for active, `Icons.history` for recent

**Validation:**
- Section headers display with icons
- Headers use primary color
- Spacing looks balanced

**Dependencies:** Task 1

---

### 5. Improve Empty States and Status Bar
**Description:** Modernize the empty state when no tasks exist and update the status bar styling.

**Changes:**
- Update empty state to centered Column with icon (64px) + title + subtitle
- Use onSurfaceVariant color with opacity for icon
- Modernize status bar to inline info banner style
- Update loading spinner to be inline with text

**Validation:**
- Empty state displays centered when no tasks exist
- Status bar shows loading state correctly
- Text and icons use appropriate colors

**Dependencies:** Task 1

---

### 6. Modernize Calendar Screen Daily Summary
**Description:** Update the daily summary container below the calendar to use gradient background and improved typography.

**Changes:**
- Add gradient background (primaryContainer)
- Add box shadow for depth
- Increase padding to 24px
- Add calendar icon next to date
- Update typography for date and task count
- Round corners (20px)

**Validation:**
- Daily summary displays with gradient background
- Date and task count are visible and readable
- Container has subtle shadow
- Updates when different date selected

**Dependencies:** None

---

### 7. Modernize Calendar Task History Cards
**Description:** Update `_TaskHistoryCard` widget to match Reports screen card styling.

**Changes:**
- Change Card to elevation: 0 with outlined border
- Add BorderRadius.circular(16)
- Wrap elapsed time in colored container (top-right)
- Add schedule icon next to start time
- Update status chip styling to smaller, refined design
- Reduce card margin to match Reports (bottom: 12px)
- Update padding to 16px all sides

**Validation:**
- Task history cards match Reports visual style
- Tap to navigate works correctly
- Elapsed time and status display correctly
- Cards render properly in list

**Dependencies:** None

---

### 8. Improve Calendar Empty State
**Description:** Update calendar empty state to centered icon + text pattern.

**Changes:**
- Center empty state column
- Add large icon (Icons.inbox_outlined or Icons.event_busy, 64px)
- Add title "No tasks on this day"
- Add subtitle "Start tracking to see tasks here"
- Use onSurfaceVariant color with opacity

**Validation:**
- Empty state displays when no tasks for selected date
- Icon and text are centered
- Text is readable with appropriate colors

**Dependencies:** None

---

### 9. Update Calendar Section Styling
**Description:** Add section label above task list and update spacing.

**Changes:**
- Add "TASKS FOR [DATE]" label with letterSpacing
- Style as labelLarge with onSurfaceVariant color
- Add consistent padding (16px horizontal)
- Update task list to use SliverPadding if not already

**Validation:**
- Section label displays above task list
- Spacing is consistent with other screens
- Date updates when selection changes

**Dependencies:** Task 7

---

### 10. Final Visual Polish and Testing
**Description:** Review all screens for consistency, test on device, and make final adjustments.

**Changes:**
- Verify all spacing matches design doc (16px standard margins)
- Ensure all cards use same border radius (16px)
- Check gradient backgrounds render correctly
- Verify icons are consistent (outlined variants)
- Test in both light and dark themes
- Run on connected device

**Validation:**
- All three screens (Tasks, Calendar, Reports) have consistent visual style
- App compiles with no errors or warnings
- All existing functionality works correctly
- Visual appearance matches design specification
- Both light and dark themes look good

**Dependencies:** All previous tasks

---

## Estimated Effort
- **Total tasks:** 10
- **Estimated time:** 2-3 hours
- **Parallelizable work:** Tasks 6-9 can be done independently from Tasks 1-5

## Notes
- Test each screen on device after changes
- Use hot reload for rapid iteration
- Refer to Reports screen implementation for styling patterns
- Keep changes focused on visual styling (no business logic changes)
