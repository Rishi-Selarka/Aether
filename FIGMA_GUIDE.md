# Figma Design Guide - City Architect

## What to Do in Figma (Phase 1)

### Step 1: Create New File
1. Open **Figma** (figma.com or desktop app)
2. File → New Design File
3. Name it: **City Architect - Swift Student Challenge 2026**

### Step 2: Set Up Pages
Create 4 pages (tabs at top):
- **Design System** (colors, typography, spacing)
- **Screens** (all 14 screens)
- **Components** (reusable elements)
- **Prototype** (interactive flow)

### Step 3: Design System (Do This First)

**Colors** - Create as Color Styles (right panel → Local styles):
```
Background:     #000000 (true black)
Surface:        #1C1C1E (cards/panels)
Surface Elevated: #2C2C2E
Border:         #38383A

Primary:        #007AFF (iOS blue)
Success:        #34C759 (green)
Warning:        #FF9500 (orange)
Error:          #FF3B30 (red)

Text Primary:   #FFFFFF
Text Secondary: #98989D
Text Tertiary:  #636366
```

**Typography** - Create as Text Styles:
```
Display Large:  SF Pro Rounded, Bold, 48pt
Heading 1:      SF Pro Rounded, Semibold, 28pt
Heading 2:      SF Pro Rounded, Semibold, 24pt
Heading 3:      SF Pro Rounded, Semibold, 20pt
Body:           SF Pro Text, Regular, 17pt
Caption:        SF Pro Text, Regular, 13pt
Code:           SF Mono, Regular, 14pt
```

**Spacing** - Document the 8pt grid:
- 8, 16, 24, 32, 40, 48, 64, 80pt

**Corner Radius**: 12pt, 16pt, 20pt only

### Step 4: Use Figma Make AI (If Available)
1. Create New → Make (AI generation)
2. Copy the **Master Context Prompt** from plan.md Figma section
3. Generate each of the 14 screens using the provided prompts
4. Refine with follow-up prompts if needed

### Step 5: Screen Priority Order
Generate in this order (most important first):
1. **Builder View** - Main canvas (90% of app)
2. **Tier Map View** - Navigation hub
3. **Onboarding View** - First impression
4. **Simulation Overlay** - Particle wow factor
5. **Inspector Panel** - Evaluation results
6. Learn More Sheet
7. Code View (split screen)
8. Glossary View
9. Recipe Book View
10. Comparison View
11. Achievement View
12. Tier Detail View
13. Tutorial Overlay
14. Settings View

### Step 6: Key Components to Design
- **Node Card** (100x100pt): Icon + label, dark gray, 16pt radius
- **Connection Line**: Curved bezier, 3pt stroke, blue gradient
- **Particle** (12pt circle): Blue with glow effect
- **Button Primary**: Blue #007AFF, white text, 16pt radius
- **Button Secondary**: Gray fill, blue text
- **Tier Card**: 200pt height, icon + title + status

### Step 7: Canvas Size
- Use **iPad Pro 12.9"** frame: **2048 x 2732 px**
- Portrait orientation
- Enable 8pt grid (View → Layout Grids)

### Step 8: Export for Development
When designs are ready:
- Export each screen as PNG @2x
- Name: 01-onboarding.png, 02-tier-map.png, etc.
- Copy color hex codes to ColorSystem.swift
- Copy spacing/sizing to LayoutConstants.swift

---

## Quick Reference: Screen Layouts

**Builder View** (most complex):
- Header 80pt | Achievement row 40pt | Canvas 700pt | Toolbar 100pt | Actions 80pt
- Nodes: 100x100pt cards
- Toolbar: Horizontal scroll of 80x80pt component cards

**Tier Map**:
- 5 tier cards stacked vertically (200pt each, 32pt spacing)
- Each card: Icon 64pt | Title + status | Lock/checkmark

**All Screens**: Dark mode only, true black background

---

## Time Estimate
- Design System: 30 min
- 14 screens with Figma Make AI: 2-3 hours
- Refinement: 30 min
- **Total: 3-4 hours**
