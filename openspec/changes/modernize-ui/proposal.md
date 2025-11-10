# Proposal: Modernize UI

**Change ID:** `modernize-ui`  
**Status:** Draft  
**Created:** 2025-11-10  
**Author:** AI Assistant

## Problem Statement

The Tasks and Calendar screens use an older, less polished UI style compared to the recently modernized Reports screen. The visual inconsistency creates a disjointed user experience, and the current layouts lack:

- Modern spacing and visual hierarchy
- Consistent card styling with rounded corners and borders
- Contextual icons for better visual scanning
- Polished empty states with centered content
- Gradient effects and elevated containers for emphasis
- Consistent typography weights and color usage

## Why

Users navigate frequently between the three main screens (Tasks, Calendar, Reports) during normal app usage. When each screen has a different visual style, it creates:

1. **Cognitive Load**: Users must mentally adjust to different layouts and styling patterns when switching screens
2. **Perceived Quality**: Inconsistent styling suggests the app is incomplete or poorly maintained
3. **Usability Issues**: Different spacing and component patterns make it harder to develop muscle memory
4. **Missed Opportunities**: The Reports screen demonstrates that modern Material Design 3 patterns improve scannability and visual appeal

By applying consistent modern styling across all screens, we create a professional, cohesive experience that helps users focus on their tasks rather than adapting to UI inconsistencies.

## Proposed Solution

Apply the same modern Material Design 3 styling from the Reports screen to the Tasks and Calendar screens, creating visual consistency across all three main views. This includes:

1. **Tasks Screen (TaskListScreen in main.dart)**
   - Convert Column-based layout to CustomScrollView with SliverList
   - Modernize active task cards with gradient backgrounds
   - Update stopped task cards to match Reports style
   - Add icons to section headers
   - Improve empty state presentation
   - Modernize status bar and action buttons

2. **Calendar Screen**
   - Update calendar header and controls styling
   - Modernize daily summary container with gradient
   - Convert task history cards to match Reports card style
   - Improve empty state with centered icon and text
   - Add section headers and better spacing

Both screens will adopt:
- Rounded cards (16px radius) with outline borders instead of heavy shadows
- Gradient containers for highlighted sections (total time, active tasks)
- Smaller, refined badge/chip designs
- Consistent icon usage (outlined variants)
- Better padding and margins (16px standard)
- Improved typography hierarchy

## Design Considerations

### Visual Consistency
All three main screens (Tasks, Calendar, Reports) will share:
- Card styling with `BorderRadius.circular(16)` and border outlines
- Gradient containers for emphasis areas
- Consistent spacing patterns (16px margins, 12px internal padding)
- Unified empty state patterns (icon + title + subtitle)

### Performance Impact
- CustomScrollView provides better scroll performance for long task lists
- No performance degradation expected from styling changes
- Gradient backgrounds are efficiently rendered

### User Experience
- **Improved Scannability**: Icons and consistent spacing help users find information faster
- **Better Visual Hierarchy**: Gradients and typography weights guide attention
- **Professional Appearance**: Modern styling increases user confidence in the app
- **Consistency**: Users develop muscle memory across all screens

### Implementation Scope
This change focuses purely on UI/styling updates:
- **In Scope**: Visual styling, layout structure, spacing, colors, typography
- **Out of Scope**: Business logic, data models, API changes, new features

## Dependencies

- Depends on: `add-reports-screen` (provides the reference styling)
- Blocks: None
- Related: Future theming improvements could build on this foundation

## Risks and Mitigations

**Risk:** Breaking existing widget layouts  
**Mitigation:** Test on connected device after each screen update; changes are purely cosmetic

**Risk:** Inconsistent styling between screens  
**Mitigation:** Extract common styling patterns; document design tokens

**Risk:** Regression in accessibility (contrast, touch targets)  
**Mitigation:** Maintain Material 3 defaults which ensure accessibility compliance

## Success Criteria

- [ ] Tasks screen matches Reports screen visual style
- [ ] Calendar screen matches Reports screen visual style  
- [ ] All cards use consistent rounded borders and spacing
- [ ] Empty states use centered icon + text pattern
- [ ] Section headers include contextual icons
- [ ] Gradient containers used for emphasis (active tasks, daily summary)
- [ ] App renders correctly on test device with no visual regressions
- [ ] No compilation errors or warnings introduced

## Open Questions

None at this time.
