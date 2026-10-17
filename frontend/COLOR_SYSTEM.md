# Shri Nrityalaya Academy — Centralized Color System

> **Single Source of Truth**: All colors across the entire application are defined and maintained exclusively in [`lib/core/theme/app_colors.dart`](lib/core/theme/app_colors.dart).  
> **Zero Inline Colors**: No screen, widget, or component contains hardcoded `Color(0x...)` values. Changing any color in `AppColors` instantly updates the entire app end-to-end.

---

## 1. Architectural Overview

The application follows a strict single-point-of-control theming architecture:

```
frontend/lib/
├── core/
│   └── theme/
│       └── app_colors.dart        <-- [PRIMARY SINGLE SOURCE OF TRUTH]
├── features/
│   ├── acharya_dashboard/         <-- References AppColors
│   ├── attendance/                <-- References AppColors
│   ├── auth/                      <-- References AppColors
│   ├── dashboard/                 <-- References AppColors (Student, Teacher, Parent)
│   ├── directory/                 <-- References AppColors
│   ├── events/                    <-- References AppColors
│   ├── fees/                      <-- References AppColors
│   ├── learning/                  <-- References AppColors
│   ├── messaging/                 <-- References AppColors
│   ├── payments/                  <-- References AppColors
│   ├── profile/                   <-- References AppColors
│   ├── progress/                  <-- References AppColors
│   └── students/                  <-- References AppColors
└── shared/
    └── widgets/                   <-- References AppColors
```

---

## 2. Palette Categories in `AppColors`

`AppColors` is organized into 6 semantic sections:

### 2.1 Core Brand Palette & Gradients
The foundational colors establishing the academy's traditional yet modern aesthetic.

| Constant Name | Hex Value | Role / Usage |
| :--- | :--- | :--- |
| `AppColors.primaryNavy` | `0xFF142448` | Primary brand navy blue used in app header, main app bar, and key buttons. |
| `AppColors.deepNavy` | `0xFF0E1A35` | Deep navy used for gradients and dark container depth. |
| `AppColors.primaryGold` | `0xFFF5C542` | Primary vibrant academy gold for buttons, active tabs, and primary highlights. |
| `AppColors.lightGold` | `0xFFFFD968` | Light golden yellow for soft gold borders and subtle highlights. |
| `AppColors.warmCream` | `0xFFFFF8E8` | Warm cream background tone for pages and light container fill. |
| `AppColors.textPrimary` | `0xFF26334A` | Primary dark navy text color for high-contrast titles and body content. |
| `AppColors.mutedText` | `0xFF667085` | Muted gray text for subtitles, placeholders, and secondary hints. |
| `AppColors.success` | `0xFF2E8B57` | Standard success green for confirmations, active states, and approved items. |
| `AppColors.warning` | `0xFFD97706` | Warning amber/orange for alerts, pending statuses, and caution badges. |
| `AppColors.error` | `0xFFC2413B` | Error crimson red for validation alerts, danger messages, and failures. |
| `AppColors.gradientNavy` | `LinearGradient` | Standard vertical gradient from `primaryNavy` to `deepNavy`. |

---

### 2.2 Navy, Midnight & Deep Accent Shades
Used for dark hero banners, modal headers, dark pill buttons, active selection states, and elevation shadows.

| Constant Name | Hex Value | Role / Description |
| :--- | :--- | :--- |
| `AppColors.navyHeader` | `0xFF0E1D3A` | Deep midnight navy used for hero banners, page headers, and dark surfaces. |
| `AppColors.darkNavySurface` | `0xFF182232` | Rich dark navy used for button backgrounds and dark badges. |
| `AppColors.navyDarkPill` | `0xFF101F3E` | Midnight navy pill background and action button color. |
| `AppColors.navyAcharya` | `0xFF15264F` | Rich royal navy used in Acharya dashboard header and cards. |
| `AppColors.navyHeroDeep` | `0xFF0B1B3B` | Very deep navy for gradient headers. |
| `AppColors.navyCardFill` | `0xFF192B4D` | Navy card container fill. |
| `AppColors.navyCardStroke` | `0xFF2B3548` | Subtle dark navy card stroke. |
| `AppColors.navyGradientMid` | `0xFF2E4470` | Medium navy shade for hero gradients. |
| `AppColors.navyBgBottom` | `0xFF0A162C` | Deepest midnight navy bottom gradient stop. |
| `AppColors.navyBgTop` | `0xFF14284B` | Deep navy top gradient stop. |
| `AppColors.navyCardBottom` | `0xFF0E1C36` | Dark navy card gradient bottom tone. |
| `AppColors.navyCardTop` | `0xFF1A2F56` | Navy card gradient top tone. |
| `AppColors.navyCircleButton`| `0xFF1A2D52` | Navy circular button background. |
| `AppColors.navyDarkBorder` | `0xFF1B2B48` | Dark navy border tone. |
| `AppColors.navyFieldBorder`| `0xFF1E2F4D` | Navy input field border. |
| `AppColors.navyCardBorder` | `0xFF1F2B3E` | Navy card border for attendance cards. |
| `AppColors.navyBorderSlate`| `0xFF1F2A44` | Dark slate navy border. |
| `AppColors.navyBatchBanner`| `0xFF2B3E5E` | Navy background for batch banner. |
| `AppColors.navyNavInactive`| `0xFF3A4152` | Muted navy gray for inactive bottom navigation items. |
| `AppColors.navyDeepAcharya`| `0xFF0F1D3F` | Deep navy tone used in Acharya theme. |

---

### 2.3 Temple Gold, Ochre & Brass Accents
Emulating traditional Indian brass lamps, temple architecture borders, and golden ornaments.

| Constant Name | Hex Value | Role / Description |
| :--- | :--- | :--- |
| `AppColors.goldBright` | `0xFFE6C365` | Radiant temple gold used for header typography, badge text, and gold accents. |
| `AppColors.goldBorder` | `0xFFD5B258` | Classic golden ochre for cards, active borders, and gold buttons. |
| `AppColors.goldFrameBorder`| `0xFFC8A752` | Refined gold frame border for navy cards and inset headers. |
| `AppColors.goldAccentLight`| `0xFFDEC992` | Soft gold accent for card frames and star badges. |
| `AppColors.goldStarBadge` | `0xFFDEC070` | Gold star badge fill and circular achievement icons. |
| `AppColors.goldTitle` | `0xFFE5C165` | Warm gold for card titles and pill badges. |
| `AppColors.goldHeaderAccent` | `0xFFE6C56A` | Luminous gold for hero headers and subtitle highlights. |
| `AppColors.goldTabIndicator` | `0xFFD5B667` | Warm gold indicator for tab selection and active states. |
| `AppColors.goldActionPill` | `0xFFC8A647` | Gold pill button background and highlight badge. |
| `AppColors.goldBadgeBorder` | `0xFFC8A654` | Gold badge border tone. |
| `AppColors.goldOchreIcon` | `0xFFC99E32` | Antique ochre gold for icons and borders. |
| `AppColors.goldOchreDeep` | `0xFFCBA43B` | Deep ochre gold for action badges. |
| `AppColors.goldBrightAccent` | `0xFFD8B45A` | Bright golden yellow for badges and highlights. |
| `AppColors.goldWarmBorder` | `0xFFEAD49B` | Warm light gold border for avatar frames and chips. |
| `AppColors.goldMetallic` | `0xFFD4AF37` | Classic metallic gold used in Acharya theme. |
| `AppColors.goldLightAccent`| `0xFFE8C970` | Light gold accent color. |
| `AppColors.goldPaleChip` | `0xFFF6E8B4` | Pale gold background for badges and chips. |
| `AppColors.goldAvatarText` | `0xFF7A5C22` | Deep golden brown text for initials avatar. |
| `AppColors.goldTitleBrown` | `0xFF8E6814` | Warm golden brown text for card headers. |
| `AppColors.goldLinkText` | `0xFF8E6E26` | Golden brown text for inline links and interactive buttons. |
| `AppColors.goldHintText` | `0xFF9B7828` | Gold hint text for input fields and placeholders. |
| `AppColors.goldAvatarBorder`| `0xFFB89648` | Golden ochre border for user avatars. |
| `AppColors.goldPrimaryAmber`| `0xFFC59B38` | Rich amber gold for buttons and accents. |
| `AppColors.goldIconTint` | `0xFFC59B3E` | Warm amber gold for circular action icons. |
| `AppColors.goldPrimaryEvent`| `0xFFC8A248` | Rich golden yellow for event action cards. |
| `AppColors.goldActionButton`| `0xFFD4A736` | Vibrant gold button fill. |
| `AppColors.goldTitleSoft` | `0xFFE2BE62` | Soft golden ochre for title text. |
| `AppColors.goldTempleLine` | `0xFFE6D9A8` | Temple line illustration gold stroke. |
| `AppColors.bronzeOchreText`| `0xFF7D5311` | Deep bronze ochre text for warning badges and chips. |

---

### 2.4 Warm Creams, Ivory & Neutral Surfaces
Creating a warm, non-stark background reminiscent of natural parchment and temple courtyards.

| Constant Name | Hex Value | Role / Description |
| :--- | :--- | :--- |
| `AppColors.creamSheetBackground` | `0xFFF6EFE0` | Light warm cream for modal sheets and background tiles. |
| `AppColors.creamCardBackground` | `0xFFFCF9F2` | Soft ivory cream for list card surfaces and containers. |
| `AppColors.creamDivider` | `0xFFEAE3D2` | Soft cream border and divider tone. |
| `AppColors.sandDivider` | `0xFFD6CEBF` | Subtle warm sand border and divider color. |
| `AppColors.sandBorderSoft` | `0xFFE5E0CC` | Soft sand border for cards and containers. |
| `AppColors.creamModalSheet` | `0xFFF8EFE0` | Ivory cream background for modal bottom sheets. |
| `AppColors.creamCardSurface` | `0xFFFAF3E3` | Warm cream card surface for attendance and directory items. |
| `AppColors.creamChipBackground` | `0xFFF3E8C8` | Light cream chip background for filters and tags. |
| `AppColors.creamEventCard` | `0xFFF5ECD7` | Cream background for event card date badges. |
| `AppColors.creamPillSoft` | `0xFFF5E6C4` | Soft cream pill background. |
| `AppColors.creamPageBackground` | `0xFFF8EFCE` | Warm page background color for acharya screens. |
| `AppColors.creamScreenBackground`| `0xFFFCF6E1` | Ivory screen background color. |
| `AppColors.creamWarmIvory` | `0xFFFFF8E1` | Warm ivory fill for cards. |
| `AppColors.pureWhite` | `0xFFFFFFFF` | Pure white for card surfaces, clean contrast text, and sheet fills. |
| `AppColors.creamAvatarFill` | `0xFFEDE1C4` | Warm cream fill for initials avatars. |
| `AppColors.creamFieldBackground`| `0xFFF3ECD9` | Cream background for text input fields. |
| `AppColors.creamPageBgWarm` | `0xFFF7F0E4` | Warm cream background for profile screens. |
| `AppColors.creamFieldBgLight` | `0xFFF7F6F2` | Very light cream background for event input fields. |
| `AppColors.creamInputFill` | `0xFFFAF9F6` | Off-white ivory fill for profile input fields. |
| `AppColors.creamSettingsTile` | `0xFFFAF6EE` | Light cream background for settings tiles and list rows. |

---

### 2.5 Slate & Neutral Text Tones
For readable typography and hierarchy across all lighting conditions.

| Constant Name | Hex Value | Role / Description |
| :--- | :--- | :--- |
| `AppColors.darkNavyText` | `0xFF141E30` | Dark navy primary text color used across headings and high-contrast labels. |
| `AppColors.textDarkPrimary` | `0xFF1B2433` | High-contrast primary text color. |
| `AppColors.textDarkSlate` | `0xFF2C3545` | Dark slate text used for list items, details, and cards. |
| `AppColors.textMutedSlate` | `0xFF3E4856` | Muted slate text for subtitles, dates, and secondary item information. |
| `AppColors.textSecondarySlate` | `0xFF4A5568` | Secondary slate text for metadata, labels, and timestamps. |
| `AppColors.textNeutralGray` | `0xFF4B5563` | Neutral slate gray for secondary labels and descriptions. |
| `AppColors.textMutedCool` | `0xFF6B7280` | Cool gray text for hints and secondary icons. |
| `AppColors.slateBorderLight` | `0xFFCBD5E1` | Light slate border for disabled controls. |
| `AppColors.slateUnselectedIcon` | `0xFF525B6C` | Slate unselected icon color. |

---

### 2.6 Status & Functional Colors
For real-time operational feedback, badges, and attendance recording.

| Constant Name | Hex Value | Role / Description |
| :--- | :--- | :--- |
| `AppColors.greenPresent` | `0xFF1B6342` | Forest emerald green for attendance present badges and success tags. |
| `AppColors.greenBadgeBg` | `0xFFCBEAD8` | Light mint green background for present/success badges. |
| `AppColors.greenPillBg` | `0xFFC7EBDD` | Mint green pill background for active status indicators. |
| `AppColors.greenSoftBg` | `0xFFD4EFE2` | Soft pale green background for confirmed items. |
| `AppColors.greenBadgeDark` | `0xFF216E4E` | Dark emerald green for badge typography and check icons. |
| `AppColors.greenCheckmark` | `0xFF2FA35A` | Vibrant green checkmark icon. |
| `AppColors.greenSuccessIcon`| `0xFF3FA66B` | Emerald green icon color for verified and completed states. |
| `AppColors.crimsonAbsent` | `0xFF942921` | Crimson red used for absent student tags, overdue badges, and errors. |
| `AppColors.crimsonAbsentButton` | `0xFFA94444` | Crimson red for absent toggle button and alerts. |
| `AppColors.crimsonDueBg` | `0xFFFCE6E5` | Light blush pink background for fee due and alert banners. |
| `AppColors.crimsonDueBorder`| `0xFFF3B7B4` | Blush red border for fee due and alert containers. |
| `AppColors.crimsonBadgeBorder` | `0xFFF7C9C7` | Soft rose border for fee due badges. |
| `AppColors.crimsonErrorBannerBg` | `0xFFFDE8E8` | Soft rose-red background for error banners. |
| `AppColors.crimsonDarkText`| `0xFF8B1A1A` | Dark crimson text for fee due and error banners. |
| `AppColors.burgundyLogout` | `0xFF932738` | Burgundy red for logout buttons and danger actions. |
| `AppColors.blueAccent` | `0xFF2B6CB0` | Cobalt blue accent for special learning indicators. |

---

## 3. How to Change the App Palette from a Single Place

To restyle or re-theme the entire application, simply update the hex values inside [`lib/core/theme/app_colors.dart`](lib/core/theme/app_colors.dart):

```dart
// Example: To make the header navy darker or shift to royal blue:
static const Color navyHeader = Color(0xFF081226); // Formerly 0xFF0E1D3A

// Example: To shift the temple gold to a warmer rose-gold or bright champagne:
static const Color goldBright = Color(0xFFF0D078); // Formerly 0xFFE6C365
```

Because every screen, widget, card, and button across the app imports and binds to `AppColors`, hot-reloading or rebuilding Flutter applies the update globally across all user roles (Acharya, Teacher, Student, Parent).

---

## 4. Coding Standard for Future Development

When adding new screens or widgets:
1. **Never** write inline `Color(0x...)` or `Color.fromRGBO(...)` directly in UI code.
2. Select an existing color token from `AppColors`.
3. If an entirely new brand tint is introduced, add it to `AppColors` with a neat doc comment, and reference it via `AppColors.<colorName>`.
