# Design: Modernize UI

## Overview

This design documents the visual and structural changes to bring the Tasks and Calendar screens in line with the modern styling already applied to the Reports screen. The goal is visual consistency using Material Design 3 patterns.

## Design Principles

1. **Consistency**: All screens share the same card styles, spacing, and component patterns
2. **Hierarchy**: Use gradients, typography, and spacing to guide user attention
3. **Scannability**: Icons and visual grouping help users process information quickly
4. **Minimalism**: Reduce visual clutter through thoughtful spacing and subtle styling
5. **Material Design 3**: Leverage MD3 tokens (containers, outlines, tonal surfaces)

## Component Patterns

### Card Styling
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: theme.colorScheme.outlineVariant,
      width: 1,
    ),
  ),
  margin: const EdgeInsets.only(bottom: 12),
  // content...
)
```

### Gradient Containers (Emphasis)
Used for: Active task cards, daily summary, total time displays

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        theme.colorScheme.primaryContainer,
        theme.colorScheme.primaryContainer.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: theme.colorScheme.primary.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
)
```

### Section Headers
```dart
Row(
  children: [
    Icon(Icons.relevant_icon, size: 20, color: theme.colorScheme.primary),
    const SizedBox(width: 8),
    Text(
      'Section Title',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    ),
  ],
)
```

### Empty States
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(
      Icons.relevant_icon,
      size: 64,
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
    ),
    const SizedBox(height: 16),
    Text(
      'Primary Message',
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
    if (hasSecondaryMessage) ...[
      const SizedBox(height: 8),
      Text(
        'Secondary message',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  ],
)
```

### Badge/Chip Styling
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: theme.colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.icon, size: 12),
      const SizedBox(width: 4),
      Text(
        'Label',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
)
```

## Tasks Screen Layout

### Structure Changes
- Replace Column with CustomScrollView + SliverList
- Group active tasks in prominent section at top
- Separate recent/stopped tasks below

### Visual Updates

**Active Task Cards:**
- Gradient background (primaryContainer)
- Box shadow for elevation
- Large elapsed time display with tabular figures
- Icon buttons for play/pause/stop
- Status badge (Running/Paused)

**Recent Task Cards:**
- Outlined border style matching Reports
- Elapsed time in colored container (top-right)
- Start button as icon
- Consistent padding (16px)

**Section Headers:**
- Icon + bold text
- Primary color accent
- 16px padding around

**Status Bar:**
- Convert to modern info banner
- Loading spinner inline with text

**FAB:**
- Keep extended style
- Ensure proper elevation

## Calendar Screen Layout

### Structure Changes
- Keep TableCalendar widget as-is (works well)
- Update summary bar below calendar
- Modernize task history cards

### Visual Updates

**Calendar Widget:**
- Keep existing TableCalendar styling (already modern)
- Selected day uses primary color
- Today uses primary with opacity
- Markers as small dots

**Daily Summary Bar:**
- Gradient background (primaryContainer)
- Icon + date on left
- Task count + total time on right
- Rounded top corners
- Box shadow for depth

**Task History Cards:**
- Match Reports card styling
- Outlined border, 16px radius
- Time badge in colored container
- Status chip with appropriate color
- Icon for start time
- Reduced margin between cards

**Empty State:**
- Centered column
- Large icon (64px)
- Title + subtitle text
- Proper color opacity

## Spacing Standards

- **Screen margins**: 16px horizontal
- **Card margins**: 0px horizontal (within padded container), 12px bottom
- **Card padding**: 16px all sides
- **Section padding**: 16px all sides
- **Icon spacing**: 8px from text
- **Vertical rhythm**: 8px, 12px, 16px based on hierarchy

## Typography

- **Screen titles**: `titleLarge` / `headlineSmall`
- **Section headers**: `titleMedium` + bold
- **Card titles**: `titleMedium` + semi-bold (w600)
- **Body text**: `bodyMedium`
- **Metadata**: `bodySmall`
- **Labels/chips**: `labelSmall` / `labelMedium`
- **Large numbers** (elapsed time): `displaySmall` / `headlineMedium` + bold + tabular figures

## Color Usage

- **Primary**: Headers, icons, emphasis
- **PrimaryContainer**: Gradient backgrounds for highlighted sections
- **OnPrimaryContainer**: Text on primary containers
- **Surface**: Card backgrounds
- **OutlineVariant**: Card borders
- **OnSurfaceVariant**: Secondary text, icons
- **SecondaryContainer**: Tags, secondary badges
- **Semantic colors**: Green (running), Orange (paused), Grey (stopped)

## Implementation Notes

1. Start with Tasks screen, validate on device
2. Then Calendar screen, validate on device
3. Extract common styling constants if repetition is high
4. Ensure all Material 3 widgets use default accessibility settings
5. Test in both light and dark themes
