# Proposal: Add Task Grouping by Project/Client

## Overview
Enhance the existing Category system to support task grouping for tracking time by customer, project, or client. This change improves the existing category functionality with better labeling, visual grouping, and filtering across all three main screens (Tasks, Calendar, Reports).

## Problem Statement
Users need to track time spent on tasks for specific customers or projects. While the app currently has a Category system, it lacks:
- Clear semantic labeling (users don't know categories can represent customers/projects)
- Visual grouping of tasks by category in the task list
- Category-based filtering in the calendar view
- Grouped time totals in reports by category

This makes it difficult to answer questions like "How much time did I spend on Customer X this week?" or "What tasks did I work on for Project Y yesterday?"

## Proposed Solution
Enhance the existing Category system without breaking changes:

1. **Improved Labeling**: Rename UI labels from "Category" to "Project/Client" (or configurable label) while keeping the underlying data model unchanged
2. **Task List Grouping**: Add optional grouping in the Tasks screen to show tasks organized by category with section headers
3. **Calendar Filtering**: Add category filter to the Calendar screen to view tasks for specific customers/projects
4. **Enhanced Reports**: Add category-grouped time totals and visual category indicators in the Reports screen

## Benefits
- **No schema changes**: Leverages existing Category infrastructure
- **Better UX**: Users can immediately see time spent per customer/project
- **Backward compatible**: Existing data and features continue to work
- **Flexible terminology**: Can be used for customers, clients, projects, or generic categories

## Scope
**In Scope:**
- UI relabeling for better semantics
- Task list visual grouping by category
- Calendar category filtering
- Reports with category-based grouping and totals
- Category color coding across all screens

**Out of Scope:**
- Hierarchical categories (e.g., Customer → Projects)
- Category-based time budgets or billing
- Multi-category assignment per task
- Schema changes to the database

## Dependencies
- Depends on existing Category system (already implemented)
- No new external dependencies required

## Alternatives Considered
1. **Add separate Customer field**: Would require schema migration and duplicate data
2. **Hierarchical system**: Too complex for initial requirement; can be added later if needed
3. **Use Tags for grouping**: Tags are meant for flexible labeling, not primary grouping

## Success Criteria
- Users can easily identify and filter tasks by customer/project
- All three screens (Tasks, Calendar, Reports) show category groupings
- No breaking changes to existing data or functionality
- Category colors provide visual distinction across screens
