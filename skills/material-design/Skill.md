---
name: Material Design Expert
description: Implements Material Design 3 (Material You) principles: components, color, typography, spacing, motion, and theming for web, mobile, and desktop applications.
version: 1.0.0
---

# ⚠️ MANDATORY: Material Design Expert Skill

## 🚨 WHEN YOU MUST USE THIS SKILL

**Mandatory triggers:**
1. Building UIs following Material Design 3 principles
2. Implementing Material Design color systems
3. Creating Material Design themes
4. Using Material UI library components
5. Designing for Material Design consistency

**This skill is MANDATORY because:**
- Ensures consistent Material Design implementation
- Improves user experience through familiar patterns
- Maintains accessibility standards
- Reduces design inconsistencies
- Improves development efficiency

**ENFORCEMENT:**

**P1 Violations (High - Quality Failure):**
- Ignoring Material Design principles
- Inconsistent color usage
- Poor typography hierarchy
- Missing accessibility features
- Inadequate motion/animation

**P2 Violations (Medium - Efficiency Loss):**
- Not using Material Design components
- Overriding Material styles unnecessarily
- Inconsistent spacing/layout

**Blocking Conditions:**
- Must follow Material Design 3 principles
- Color system must be consistent
- Typography must have proper hierarchy
- Accessibility must be maintained

---

## Purpose

Implements Google's Material Design 3 (Material You) principles in web, mobile, and desktop applications.

## Material Design 3 Core Principles

### 1. Material
- Surfaces and elevation
- Shadows and depth
- Physical metaphors

### 2. Color
- Dynamic color system
- Semantic color tokens
- Contrast requirements

### 3. Typography
- Type scale (Display, Headline, Title, Body, Label)
- Proper hierarchy and readability
- Font families and weights

### 4. Spacing
- 4px base unit grid
- Consistent margins and padding
- Responsive spacing

### 5. Motion
- Easing and timing
- Transitions and animations
- Principles: Responsive, Natural, Purposeful

### 6. Iconography
- Consistent 24px grid
- Proper states (filled, outlined, rounded)
- Clear and recognizable

## Color System

- **Primary**: Main brand color
- **Secondary**: Supporting brand color
- **Tertiary**: Accent color
- **Error**: Error states
- **Neutral**: Backgrounds and surfaces

## Typography Scale

```
Display Large: 57sp, Weight 400
Display Medium: 45sp, Weight 400
Display Small: 36sp, Weight 400
Headline Large: 32sp, Weight 400
Headline Medium: 28sp, Weight 400
Headline Small: 24sp, Weight 500
Title Large: 22sp, Weight 500
Title Medium: 16sp, Weight 500
Title Small: 14sp, Weight 500
Body Large: 16sp, Weight 400
Body Medium: 14sp, Weight 400
Body Small: 12sp, Weight 400
Label Large: 14sp, Weight 500
Label Medium: 12sp, Weight 500
Label Small: 11sp, Weight 500
```

## Spacing Grid (4px base)

- xxs: 4px
- xs: 8px
- sm: 12px
- md: 16px
- lg: 20px
- xl: 24px
- 2xl: 32px
- 3xl: 40px

## Anti-Patterns

### ❌ Anti-Pattern: Ignoring Color Contrast

**Wrong:**
```
Light gray text (#999999) on light background (#EEEEEE)
Contrast ratio too low - fails WCAG
```

**Correct:**
```
Use Material Design color tokens with guaranteed contrast
Primary text: #212121 on light backgrounds
Contrast ratio ≥ 4.5:1
```

---

## Material UI Integration (React/Angular)

**React Material UI:**
```typescript
import { Button, TextField, ThemeProvider, createTheme } from '@mui/material';

const theme = createTheme({
  palette: {
    primary: { main: '#6200EE' },
    secondary: { main: '#03DAC6' }
  },
  typography: {
    fontFamily: 'Roboto',
  }
});

<ThemeProvider theme={theme}>
  <Button variant="contained">Click me</Button>
</ThemeProvider>
```

## References

**Based on:**
- CLAUDE.md Section 3 (Available Skills Reference - material-design)
- Material Design 3 spec: https://m3.material.io/
- Material UI library: https://mui.com/

**Related skills:**
- `maintine-ui` - Complementary UI library
