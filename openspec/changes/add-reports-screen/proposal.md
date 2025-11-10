# Add Reports Screen

## Overview
Add a reports screen accessible from the bottom navigation bar that allows users to filter tasks by tags and categories, view aggregated time totals, and export filtered results to CSV format.

## Motivation
Users need a way to analyze their time tracking data by filtering tasks based on tags and categories. This will provide insights into how time is distributed across different projects, activities, or contexts. The ability to export to CSV enables further analysis in external tools like spreadsheets.

## Problem Statement
Currently, users can:
- View tasks in a list (Tasks screen)
- View tasks by date (Calendar screen)

However, there is no way to:
- Filter tasks by specific tags or categories
- See total time spent across filtered tasks
- Export aggregated time data for external analysis

## Proposed Solution
Add a new "Reports" screen as the third tab in the bottom navigation bar with the following capabilities:

1. **Filter Selection**: Users can select one or more tags and/or one category to filter tasks
2. **Time Aggregation**: Display total hours, minutes, and seconds for all tasks matching the applied filters
3. **CSV Export**: Export the filtered task list with totals to a CSV file

## Success Criteria
- [x] Reports screen appears as third tab in bottom navigation
- [x] Users can select multiple tags and a single category for filtering
- [x] Total elapsed time displays correctly for filtered tasks
- [x] CSV export includes all relevant task data and totals
- [x] UI is intuitive and follows existing app design patterns

## Non-Goals
- Date range filtering (can be added later if needed)
- Graphical visualizations (charts, graphs)
- Report templates or saved filters
- Cloud sync or sharing of reports

## Dependencies
- Existing task repository filtering methods
- Existing tag and category repositories
- File system access for CSV export

## Related Changes
None currently; this is a new standalone feature.
