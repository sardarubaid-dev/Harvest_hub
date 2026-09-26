---
name: HarvestHub Design System
colors:
  surface: '#f7faf3'
  surface-dim: '#d8dbd4'
  surface-bright: '#f7faf3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f5ee'
  surface-container: '#ecefe8'
  surface-container-high: '#e6e9e2'
  surface-container-highest: '#e0e3dd'
  on-surface: '#191d19'
  on-surface-variant: '#40493d'
  inverse-surface: '#2d312d'
  inverse-on-surface: '#eff2eb'
  outline: '#707a6c'
  outline-variant: '#bfcaba'
  surface-tint: '#1b6d24'
  primary: '#0d631b'
  on-primary: '#ffffff'
  primary-container: '#2e7d32'
  on-primary-container: '#cbffc2'
  inverse-primary: '#88d982'
  secondary: '#126d27'
  on-secondary: '#ffffff'
  secondary-container: '#9cf49c'
  on-secondary-container: '#19722b'
  tertiary: '#4d5950'
  on-tertiary: '#ffffff'
  tertiary-container: '#657167'
  on-tertiary-container: '#e8f5e9'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a3f69c'
  primary-fixed-dim: '#88d982'
  on-primary-fixed: '#002204'
  on-primary-fixed-variant: '#005312'
  secondary-fixed: '#9ff79f'
  secondary-fixed-dim: '#83da85'
  on-secondary-fixed: '#002105'
  on-secondary-fixed-variant: '#005318'
  tertiary-fixed: '#d9e6da'
  tertiary-fixed-dim: '#bdcabe'
  on-tertiary-fixed: '#131e17'
  on-tertiary-fixed-variant: '#3e4a41'
  background: '#f7faf3'
  on-background: '#191d19'
  surface-variant: '#e0e3dd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.015em
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-xl-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.03em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 1rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style
The design system establishes a premium, direct-to-consumer agricultural exchange that bridges conscious consumers, independent farmers, and platform administrators. The visual direction balances the grounded authenticity of local farming with the clarity and precision of modern commerce tools.

### Design Aesthetic: Fresh Organic Modernism
- **Philosophy:** Honest, transparent, and uncluttered. UI elements feel lightweight and fresh, avoiding synthetic embellishments, excessive skeuomorphism, or hyper-industrial tech aesthetics.
- **Atmosphere:** Clean open fields, tactile produce, structured data, and uncompromising readability.
- **Role Differentiation:**
  - *Consumer Interface:* Warm, inspiring, product-first discovery with generous imagery and smooth checkout pathways.
  - *Farmer Interface:* Production-grade inventory and fulfillment dashboards designed for high-efficiency data entry, batch handling, and order status tracking.
  - *Admin Interface:* Dense, analytical, high-governance control planes emphasizing auditing, verification badges, and resolution flows.

## Colors
The palette evokes agricultural vitality through balanced forest greens, fresh vegetative tints, and high-legibility earth-toned neutrals.

### Palette Architecture
- **Primary (`#2E7D32`):** Grounded agricultural green used for key actions, brand anchor moments, verified farmer badges, and active state highlights.
- **Secondary (`#66BB6A`):** Leaf accent green for progress indicators, secondary interactive states, and accent highlights.
- **Tertiary / Container Light (`#E8F5E9`):** Soft organic tint utilized for tag backgrounds, selected item cards, table row highlights, and alert containers.
- **Canvas & Surfaces:**
  - *App Background (`#F8FAF8`):* Cool-cast natural white reducing eye strain and establishing soft boundaries against pure white components.
  - *Surface Base (`#FFFFFF`):* Crisp white for cards, sheets, elevated menus, and data inputs.
- **Text & Hierarchy:**
  - *Text Primary (`#1B1F1B`):* Deep pine-charcoal delivering AA/AAA contrast ratios without the harshness of pure black.
  - *Text Secondary (`#667066`):* Mid-tone moss gray for metadata, unit pricing, column headers, and secondary labels.
- **System Feedback:**
  - *Warning (`#F59E0B`):* Harvest amber for pending verification, low stock thresholds, and dispatch alerts.
  - *Error (`#D32F2F`):* Crimson for failed payments, harvest shortages, and cancellation triggers.
  - *Info (`#0288D1`):* Cool sky blue reserved strictly for logistics tracking and platform advisories.

## Typography
Typographic rhythm relies on `Inter` across all structural tiers to prioritize cross-platform legibility, tabular numeric alignment for weights/pricing, and modern neutrality.

### Typographic Guidelines
- **Numeric Data:** Utilize tabular figures (`tnum`) for pricing, harvest dates, weight scales (e.g., kg/lb), and inventory tallies to preserve structural grid alignment.
- **Hierarchy Pairing:** Pair `headline-lg` (Semi-Bold) with `body-sm` (Regular) in dual-tier farm product listings to keep consumer focus on quality metrics and origins.
- **Capitalization:** Reserve uppercase treatment exclusively for `label-sm` when indicating system status codes (e.g., `READY`, `CONFIRMED`).

## Layout & Spacing
The layout architecture utilizes an adaptable 12-column responsive fluid grid designed to accommodate dense operational dashboards alongside visually spacious consumer catalogs.

### Breakpoints & Canvas Bounds
- **Desktop (≥ 1280px):** 12-column layout. Max container constraint of `1440px`. Column gutter at `1.5rem` (`24px`), screen margin at `2rem` (`32px`).
- **Tablet (768px – 1279px):** 8-column layout. Column gutter at `1.25rem` (`20px`), screen margin at `1.5rem` (`24px`).
- **Mobile (≤ 767px):** 4-column layout. Column gutter at `1rem` (`16px`), screen margin at `1rem` (`16px`).

### Role-Specific Composition
- **Customer Viewport:** Wide card grids (3 or 4 columns on desktop, 1 or 2 on mobile) prioritizing large produce aspect ratios (4:3) and organic certification icons.
- **Farmer Portal:** Asymmetric workspace with a persistent 280px left navigation bar, 8-column inventory/order ledger, and 4-column batch preview pane.
- **Admin Control Center:** Fluid table-dense views utilizing compact row heights (`48px`) with sticky header rows and floating batch-action rails.

## Elevation & Depth
Depth is created via soft ambient shadows tinted with deep vegetable tones rather than stark neutral blacks, simulating natural diffused daylight across clean surfaces.

### Elevation Levels
- **Level 0 (Flat):** Surface `#FFFFFF` resting directly on background `#F8FAF8` with a subtle low-contrast outline: `1px solid rgba(27, 31, 27, 0.08)`. Default state for data tables and static panels.
- **Level 1 (Card Resting):** Card container default.
  - Shadow: `0 2px 8px -2px rgba(27, 31, 27, 0.06), 0 1px 4px -1px rgba(27, 31, 27, 0.04)`.
  - Border: `1px solid rgba(27, 31, 27, 0.05)`.
- **Level 2 (Interactive Hover / Floating Panels):** Triggered when hovering over farm cards, checkout totals, or filter chips.
  - Shadow: `0 8px 24px -4px rgba(46, 125, 50, 0.08), 0 4px 12px -2px rgba(27, 31, 27, 0.04)`.
  - Border: `1px solid rgba(46, 125, 50, 0.20)`.
- **Level 3 (Modals / Overlays):** Order detail drawers, harvest batch editors, and photo zoom modals.
  - Shadow: `0 20px 40px -8px rgba(27, 31, 27, 0.16), 0 8px 16px -4px rgba(27, 31, 27, 0.08)`.
  - Backdrop: `rgba(27, 31, 27, 0.40)` with `blur(4px)`.

## Shapes
A roundedness value of `2` provides an approachable, organic character while preserving architectural balance for dense data tables.

### Corner Radius System
- **Base Components (`rounded-md`, 0.5rem / 8px):** Input fields, form selects, table row selectors, dropdown menus, and standard utility buttons.
- **Cards & Surfaces (`rounded-lg`, 1rem / 16px):** Primary marketplace cards, farm profile summaries, order summary panels, and modal windows.
- **High-Impact Containers (`rounded-xl`, 1.5rem / 24px):** Hero promotional containers, regional farm spotlight banners, and bottom sheets on mobile devices.
- **Pills (`rounded-full`):** Category filter chips, status badges, price metric tags, and avatar clips.

## Components

### Buttons
- **Primary:** Background `#2E7D32`, text `#FFFFFF`, border `none`, radius `0.5rem`. Height `44px` (desktop), `48px` (mobile). Hover: `#256628`. Active: scale `0.98`.
- **Secondary:** Background `#E8F5E9`, text `#2E7D32`, border `1px solid rgba(46, 125, 50, 0.2)`. Hover: `#D7EED9`.
- **Ghost/Tertiary:** Background `transparent`, text `#1B1F1B`. Hover: `#F0F4F0`.
- **Destructive:** Background `#D32F2F`, text `#FFFFFF`. Hover: `#B71C1C`.

### Status Badges
Rendered as pill shapes with `label-sm` font styling, combining a 6px status dot with concise label text:
- **Pending:** Background `#FEF3C7`, text `#92400E`, dot `#F59E0B`.
- **Confirmed:** Background `#E0F2FE`, text `#075985`, dot `#0288D1`.
- **Ready:** Background `#E8F5E9`, text `#1B5E20`, dot `#2E7D32`.
- **Completed:** Background `#F3F4F6`, text `#374151`, dot `#9CA3AF`.

### Marketplace Cards
- Crisp white surface (`#FFFFFF`) with `1rem` radius.
- Imagery framed at 4:3 ratio with an absolute positioned tag at the top-left (e.g., "Certified Organic", "Picked Today").
- Title in `headline-md`, origin farmer line with a 16px verified checkmark, price rendered prominently in bold tabular figures (e.g., `$4.50 / lb`), and an immediate "Add to Basket" compact button.

### Form Inputs
- Background `#FFFFFF`, border `1px solid #D6DDD6`, border radius `0.5rem`, padding `0.75rem 1rem`.
- Focus state: border `2px solid #2E7D32`, outer glow ring `0 0 0 3px rgba(46, 125, 50, 0.15)`.
- Error state: border `1px solid #D32F2F`, helper text rendered in `#D32F2F` with a leading 14px error icon.

### Checkboxes & Radio Controls
- Custom controls sized at `20px x 20px`.
- Unchecked: `1.5px solid #667066` on `#FFFFFF`.
- Checked: `#2E7D32` fill with white checkmark or center pip. Roundedness: `4px` for checkboxes, `50%` for radios.

### Role-Specific Components
- **Farmer Batch Editor:** Inline tabular rows with real-time numeric steppers for daily harvested yields and automated unit price converters.
- **Consumer Farm Provenance Bar:** Visual strip embedded on product pages displaying farm distance (`"8 miles away"`), harvest timestamp, and soil/practice certificates.
- **Admin Audit Accordion:** Multi-tier expandable inspection panel with side-by-side verification photos, identity documents, and quick-action approval switches.