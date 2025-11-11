# Tasks: Add Task Grouping by Project/Client

## Implementation Checklist

### Phase 1: Foundation & Data Layer
- [x] Add `groupByCategory` boolean to shared preferences for user preference persistence
- [x] Add repository method to get tasks grouped by category (returns Map<Category?, List<Task>>)
- [x] Add repository method to get category time totals (returns List<{category, totalSeconds, taskCount}>)
- [x] Write unit tests for new repository methods

### Phase 2: Task List Screen Enhancements
- [x] Update UI labels from "Category" to "Project/Client" in task creation/edit dialogs
- [x] Add "Group by" toggle button to task list screen app bar
- [x] Implement grouped list view with category section headers
- [x] Add category color indicator badge to existing task cards
- [x] Display task count per category in section headers
- [x] Add "Uncategorized" section for tasks without a category
- [x] Persist and restore grouping preference using shared preferences
- [x] Test grouped/ungrouped view toggling
- [x] Test with empty categories and mixed data

### Phase 3: Calendar Screen Category Filtering
- [x] Add category filter dropdown to calendar screen header
- [x] Implement category filtering logic for displayed tasks
- [x] Add visual indicator (chip/badge) showing active category filter
- [x] Add clear/remove filter action
- [x] Persist filter selection when navigating between dates
- [x] Update task cards in calendar to show category color badges
- [x] Test filter behavior with date selection changes
- [x] Test clearing filter restores all tasks

### Phase 4: Reports Screen Grouping
- [x] Add category summary section showing time totals per category
- [x] Display category name, color, total duration, and task count for each category
- [x] Sort categories by total time (descending) by default
- [x] Add tap handler to category summary items to filter tasks by that category
- [x] Ensure category grouping works with existing tag/date filters
- [x] Hide empty categories when filters are applied
- [ ] Add quick-select category chips for top categories by time
- [ ] Update reports export to include category breakdown section
- [x] Test combined filtering (tags + category)
- [x] Test empty states and edge cases

### Phase 5: Consistent Visual Design
- [x] Design and implement consistent category color badge component
- [x] Apply category badges to task cards in all three screens
- [ ] Add category display to task detail screen with tap-to-filter functionality
- [x] Update placeholder text and labels to use "Project/Client" terminology consistently
- [ ] Add tooltips/help text explaining category usage for customers/projects
- [x] Ensure dark mode compatibility for all new UI elements
- [x] Test visual consistency across all screens

### Phase 6: Testing & Polish
- [ ] Manual testing on Android: grouped task list functionality
- [ ] Manual testing on Android: calendar category filtering
- [ ] Manual testing on Android: reports category grouping
- [ ] Test with no categories (all uncategorized tasks)
- [ ] Test with single category (no grouping needed)
- [ ] Test with many categories (10+) for UI scalability
- [ ] Test preference persistence across app restarts
- [ ] Test category color indicators in light and dark themes
- [ ] Update user-facing documentation if needed
- [ ] Performance test with 100+ tasks and 10+ categories

## Dependencies & Parallelizable Work
- **Sequential**: Phase 1 must complete before Phases 2-4
- **Parallelizable**: Phases 2, 3, and 4 can be implemented independently after Phase 1
- **Sequential**: Phase 5 should come after Phases 2-4 to ensure consistent design
- **Final**: Phase 6 requires all previous phases

## Validation Points
After each phase:
- ✓ Run the app and verify new functionality works
- ✓ Check that existing functionality is not broken
- ✓ Verify visual consistency with existing UI design
- ✓ Test on physical Android device for real-world behavior

## Out of Scope (Future Enhancements)
- Hierarchical categories (Customer → Projects)
- Category-based budgets or time limits
- Custom category sort order in grouped views
- Category analytics/insights (trends, comparisons)
- Multi-category assignment per task
