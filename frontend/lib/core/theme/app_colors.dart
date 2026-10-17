import 'package:flutter/material.dart';

/// Centralized Application Color Palette for Shri Nrityalaya Academy.
///
/// Modify colors here to change the entire app's visual theme from a single place.
/// Every color in the application is strictly defined and documented in this class.
class AppColors {

  // ============================================================================
  // 1. CORE BRAND PALETTE & GRADIENTS
  // Primary brand identity colors used across app bars, key buttons, and global theme defaults.
  // ============================================================================

  /// Primary brand navy blue used in app header, main app bar, and key buttons
  static const Color primaryNavy = Color(0XFF142448);

  /// Deep navy used for gradients and dark container depth
  static const Color deepNavy = Color(0XFF0E1A35);

  /// Primary vibrant academy gold for buttons, active tabs, and primary highlights
  static const Color primaryGold = Color(0XFFF5C542);

  /// Light golden yellow for soft gold borders and subtle highlights
  static const Color lightGold = Color(0XFFFFD968);

  /// Warm cream background tone for pages and light container fill
  static const Color warmCream = Color(0XFFFFF8E8);

  /// Primary dark navy text color for high-contrast titles and body content
  static const Color textPrimary = Color(0XFF26334A);

  /// Muted gray text for subtitles, placeholders, and secondary hints
  static const Color mutedText = Color(0XFF667085);

  /// Standard success green for confirmations, active states, and approved items
  static const Color success = Color(0XFF2E8B57);

  /// Warning amber/orange for alerts, pending statuses, and caution badges
  static const Color warning = Color(0XFFD97706);

  /// Error crimson red for validation alerts, danger messages, and failures
  static const Color error = Color(0XFFC2413B);

  /// Standard brand vertical gradient from primary navy to deep midnight navy
  static const LinearGradient gradientNavy = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryNavy, deepNavy],
  );


  // ============================================================================
  // 2. NAVY, MIDNIGHT & DEEP SHADES
  // Deep royal and midnight navy tones for headers, hero containers, gradients, and dark accents.
  // ============================================================================

  /// Deep midnight navy used for hero banners, page headers, and dark surfaces
  static const Color navyHeader = Color(0XFF0E1D3A);

  /// Dark navy primary text color used across headings and high-contrast labels
  static const Color darkNavyText = Color(0XFF141E30);

  /// Dark slate text used for list items, details, and cards
  static const Color textDarkSlate = Color(0XFF2C3545);

  /// Rich dark navy used for button backgrounds and dark badges
  static const Color darkNavySurface = Color(0XFF182232);

  /// Midnight navy pill background and action button color
  static const Color navyDarkPill = Color(0XFF101F3E);

  /// Very deep navy for gradient headers
  static const Color navyHeroDeep = Color(0XFF0B1B3B);

  /// Rich royal navy used in Acharya dashboard header and cards
  static const Color navyAcharya = Color(0XFF15264F);

  /// Deep navy container accent
  static const Color navyAccentDark = Color(0XFF172A4F);

  /// Navy card container fill
  static const Color navyCardFill = Color(0XFF192B4D);

  /// Medium navy shade for hero gradients
  static const Color navyGradientMid = Color(0XFF2E4470);

  /// Subtle dark navy card stroke
  static const Color navyCardStroke = Color(0XFF2B3548);

  /// Deepest midnight navy bottom gradient stop
  static const Color navyBgBottom = Color(0XFF0A162C);

  /// Deep navy top gradient stop
  static const Color navyBgTop = Color(0XFF14284B);

  /// Dark navy card gradient bottom tone
  static const Color navyCardBottom = Color(0XFF0E1C36);

  /// Navy card gradient top tone
  static const Color navyCardTop = Color(0XFF1A2F56);

  /// Navy circular button background
  static const Color navyCircleButton = Color(0XFF1A2D52);

  /// Dark navy border tone
  static const Color navyDarkBorder = Color(0XFF1B2B48);

  /// Navy input field border
  static const Color navyFieldBorder = Color(0XFF1E2F4D);

  /// Navy card border for attendance cards
  static const Color navyCardBorder = Color(0XFF1F2B3E);

  /// Dark slate navy border
  static const Color navyBorderSlate = Color(0XFF1F2A44);

  /// Navy background for batch banner
  static const Color navyBatchBanner = Color(0XFF2B3E5E);

  /// Muted navy gray for inactive bottom navigation items
  static const Color navyNavInactive = Color(0XFF3A4152);

  /// Deep navy tone used in Acharya theme
  static const Color navyDeepAcharya = Color(0XFF0F1D3F);

  /// High contrast primary text color
  static const Color textDarkPrimary = Color(0XFF1B2433);

  /// Midnight dark navy for shadows and dark card containers (0XFF060C18) in Learning
  static const Color navyMidnight060c18 = Color(0XFF060C18);

  /// Midnight dark navy for shadows and dark card containers (0XFF081226) in Events
  static const Color navyMidnight081226 = Color(0XFF081226);

  /// Midnight dark navy for shadows and dark card containers (0XFF0A1428) in Learning
  static const Color navyMidnight0a1428 = Color(0XFF0A1428);

  /// Midnight dark navy for shadows and dark card containers (0XFF0B162C) in Profile
  static const Color navyMidnight0b162c = Color(0XFF0B162C);

  /// Dark navy slate for cards, borders, and buttons (0XFF0E1F3D) in Messaging
  static const Color navySlate0e1f3d = Color(0XFF0E1F3D);

  /// Dark navy slate for cards, borders, and buttons (0XFF112244) in Learning
  static const Color navySlate112244 = Color(0XFF112244);

  /// Dark navy slate for cards, borders, and buttons (0XFF132548) in Profile
  static const Color navySlate132548 = Color(0XFF132548);

  /// Dark navy slate for cards, borders, and buttons (0XFF14223D) in Dashboard
  static const Color navySlate14223d = Color(0XFF14223D);

  /// Royal navy blue for containers and accents (0XFF172C54) in Auth
  static const Color navyRoyal172c54 = Color(0XFF172C54);

  /// Royal navy blue for containers and accents (0XFF19305C) in Events
  static const Color navyRoyal19305c = Color(0XFF19305C);

  /// Dark navy slate for cards, borders, and buttons (0XFF1A2B49) in Dashboard
  static const Color navySlate1a2b49 = Color(0XFF1A2B49);

  /// Dark navy slate for cards, borders, and buttons (0XFF1B2B45) in Dashboard
  static const Color navySlate1b2b45 = Color(0XFF1B2B45);

  /// Dark navy slate for cards, borders, and buttons (0XFF1C2536) in Fees
  static const Color navySlate1c2536 = Color(0XFF1C2536);

  /// Dark navy slate for cards, borders, and buttons (0XFF1E2736) in Fees
  static const Color navySlate1e2736 = Color(0XFF1E2736);

  /// Dark navy slate for cards, borders, and buttons (0XFF1E293B) in Messaging
  static const Color navySlate1e293b = Color(0XFF1E293B);

  /// Dark navy slate for cards, borders, and buttons (0XFF1F2B3D) in Core/Shared
  static const Color navySlate1f2b3d = Color(0XFF1F2B3D);

  /// Royal navy blue for containers and accents (0XFF1F3868) in Learning
  static const Color navyRoyal1f3868 = Color(0XFF1F3868);

  /// Royal navy blue for containers and accents (0XFF203864) in Progress
  static const Color navyRoyal203864 = Color(0XFF203864);

  /// Royal navy blue for containers and accents (0XFF22365E) in Fees
  static const Color navyRoyal22365e = Color(0XFF22365E);

  /// Dark navy slate for cards, borders, and buttons (0XFF232C3D) in Progress
  static const Color navySlate232c3d = Color(0XFF232C3D);

  /// Royal navy blue for containers and accents (0XFF243F73) in Profile
  static const Color navyRoyal243f73 = Color(0XFF243F73);

  /// Royal navy blue for containers and accents (0XFF283E66) in Progress
  static const Color navyRoyal283e66 = Color(0XFF283E66);

  /// Royal navy blue for containers and accents (0XFF284170) in Progress
  static const Color navyRoyal284170 = Color(0XFF284170);

  /// Royal navy blue for containers and accents (0XFF3A4352) in Core/Shared
  static const Color navyRoyal3a4352 = Color(0XFF3A4352);


  // ============================================================================
  // 3. TEMPLE GOLD, OCHRE & BRASS ACCENTS
  // Temple brass and radiant gold colors for buttons, active indicators, borders, and badges.
  // ============================================================================

  /// Radiant temple gold used for header typography, badge text, and gold accents
  static const Color goldBright = Color(0XFFE6C365);

  /// Classic golden ochre for cards, active borders, and gold buttons
  static const Color goldBorder = Color(0XFFD5B258);

  /// Refined gold frame border for navy cards and inset headers
  static const Color goldFrameBorder = Color(0XFFC8A752);

  /// Soft gold accent for card frames and star badges
  static const Color goldAccentLight = Color(0XFFDEC992);

  /// Gold star badge fill and circular achievement icons
  static const Color goldStarBadge = Color(0XFFDEC070);

  /// Gold highlight for active tabs and pill buttons
  static const Color goldHighlight = Color(0XFFD5C19D);

  /// Warm gold for card titles and pill badges
  static const Color goldTitle = Color(0XFFE5C165);

  /// Luminous gold for hero headers and subtitle highlights
  static const Color goldHeaderAccent = Color(0XFFE6C56A);

  /// Warm gold indicator for tab selection and active states
  static const Color goldTabIndicator = Color(0XFFD5B667);

  /// Gold pill button background and highlight badge
  static const Color goldActionPill = Color(0XFFC8A647);

  /// Gold badge border tone
  static const Color goldBadgeBorder = Color(0XFFC8A654);

  /// Antique ochre gold for icons and borders
  static const Color goldOchreIcon = Color(0XFFC99E32);

  /// Deep ochre gold for action badges
  static const Color goldOchreDeep = Color(0XFFCBA43B);

  /// Bright golden yellow for badges and highlights
  static const Color goldBrightAccent = Color(0XFFD8B45A);

  /// Warm light gold border for avatar frames and chips
  static const Color goldWarmBorder = Color(0XFFEAD49B);

  /// Deep bronze ochre text for warning badges and chips
  static const Color bronzeOchreText = Color(0XFF7D5311);

  /// Classic metallic gold used in Acharya theme
  static const Color goldMetallic = Color(0XFFD4AF37);

  /// Light gold accent color
  static const Color goldLightAccent = Color(0XFFE8C970);

  /// Pale gold background for badges and chips
  static const Color goldPaleChip = Color(0XFFF6E8B4);

  /// Deep golden brown text for initials avatar
  static const Color goldAvatarText = Color(0XFF7A5C22);

  /// Warm golden brown text for card headers
  static const Color goldTitleBrown = Color(0XFF8E6814);

  /// Golden brown text for inline links and interactive buttons
  static const Color goldLinkText = Color(0XFF8E6E26);

  /// Gold hint text for input fields and placeholders
  static const Color goldHintText = Color(0XFF9B7828);

  /// Golden ochre border for user avatars
  static const Color goldAvatarBorder = Color(0XFFB89648);

  /// Rich amber gold for buttons and accents
  static const Color goldPrimaryAmber = Color(0XFFC59B38);

  /// Warm amber gold for circular action icons
  static const Color goldIconTint = Color(0XFFC59B3E);

  /// Rich golden yellow for event action cards
  static const Color goldPrimaryEvent = Color(0XFFC8A248);

  /// Vibrant gold button fill
  static const Color goldActionButton = Color(0XFFD4A736);

  /// Soft golden ochre for title text
  static const Color goldTitleSoft = Color(0XFFE2BE62);

  /// Temple line illustration gold stroke
  static const Color goldTempleLine = Color(0XFFE6D9A8);

  /// Dark bronze tone for typography and badges (0XFF6B5314) in Progress
  static const Color bronzeDark6b5314 = Color(0XFF6B5314);

  /// Secondary theme accent tone (0XFF8C7A5B) in Dashboard
  static const Color accentTone8c7a5b = Color(0XFF8C7A5B);

  /// Light golden amber for highlights and borders (0XFFD6B872) in Dashboard
  static const Color goldLightShadeD6b872 = Color(0XFFD6B872);


  // ============================================================================
  // 4. WARM CREAMS, IVORY & SURFACES
  // Warm cream, ivory, and soft sand tones for page backgrounds, cards, sheets, and chips.
  // ============================================================================

  /// Subtle warm sand border and divider color
  static const Color sandDivider = Color(0XFFD6CEBF);

  /// Light warm cream for modal sheets and background tiles
  static const Color creamSheetBackground = Color(0XFFF6EFE0);

  /// Soft ivory cream for list card surfaces and containers
  static const Color creamCardBackground = Color(0XFFFCF9F2);

  /// Soft cream border and divider tone
  static const Color creamDivider = Color(0XFFEAE3D2);

  /// Ivory cream background for modal bottom sheets
  static const Color creamModalSheet = Color(0XFFF8EFE0);

  /// Warm cream card surface for attendance and directory items
  static const Color creamCardSurface = Color(0XFFFAF3E3);

  /// Soft sand border for cards and containers
  static const Color sandBorderSoft = Color(0XFFE5E0CC);

  /// Light slate border for disabled controls
  static const Color slateBorderLight = Color(0XFFCBD5E1);

  /// Light cream chip background for filters and tags
  static const Color creamChipBackground = Color(0XFFF3E8C8);

  /// Cream background for event card date badges
  static const Color creamEventCard = Color(0XFFF5ECD7);

  /// Soft cream pill background
  static const Color creamPillSoft = Color(0XFFF5E6C4);

  /// Warm page background color for acharya screens
  static const Color creamPageBackground = Color(0XFFF8EFCE);

  /// Ivory screen background color
  static const Color creamScreenBackground = Color(0XFFFCF6E1);

  /// Warm ivory fill for cards
  static const Color creamWarmIvory = Color(0XFFFFF8E1);

  /// Pure white for card surfaces, clean contrast text, and sheet fills
  static const Color pureWhite = Color(0XFFFFFFFF);

  /// Warm cream fill for initials avatars
  static const Color creamAvatarFill = Color(0XFFEDE1C4);

  /// Cream background for text input fields
  static const Color creamFieldBackground = Color(0XFFF3ECD9);

  /// Warm cream background for profile screens
  static const Color creamPageBgWarm = Color(0XFFF7F0E4);

  /// Very light cream background for event input fields
  static const Color creamFieldBgLight = Color(0XFFF7F6F2);

  /// Off-white ivory fill for profile input fields
  static const Color creamInputFill = Color(0XFFFAF9F6);

  /// Light cream background for settings tiles and list rows
  static const Color creamSettingsTile = Color(0XFFFAF6EE);

  /// Soft sand neutral for cards, chips, and dividers (0XFFD1CFC9) in Profile
  static const Color sandWarmMutedD1cfc9 = Color(0XFFD1CFC9);

  /// Secondary theme accent tone (0XFFD5C18F) in Fees
  static const Color accentToneD5c18f = Color(0XFFD5C18F);

  /// Soft sand neutral for cards, chips, and dividers (0XFFD5D9E0) in Messaging
  static const Color sandWarmMutedD5d9e0 = Color(0XFFD5D9E0);

  /// Secondary theme accent tone (0XFFDEC17B) in Core/Shared
  static const Color accentToneDec17b = Color(0XFFDEC17B);

  /// Secondary theme accent tone (0XFFE0C480) in Core/Shared
  static const Color accentToneE0c480 = Color(0XFFE0C480);

  /// Warm ivory cream surface background for cards and dialogs (0XFFE2D8C3) in Events
  static const Color creamWarmLightE2d8c3 = Color(0XFFE2D8C3);

  /// Warm ivory cream surface background for cards and dialogs (0XFFE2D9C5) in Progress
  static const Color creamWarmLightE2d9c5 = Color(0XFFE2D9C5);

  /// Warm ivory cream surface background for cards and dialogs (0XFFE2E8F0) in Dashboard, Core/Shared
  static const Color creamWarmLightE2e8f0 = Color(0XFFE2E8F0);

  /// Warm ivory cream surface background for cards and dialogs (0XFFE5DAC1) in Fees
  static const Color creamWarmLightE5dac1 = Color(0XFFE5DAC1);

  /// Warm ivory cream surface background for cards and dialogs (0XFFE5E7EB) in Learning
  static const Color creamWarmLightE5e7eb = Color(0XFFE5E7EB);

  /// Warm ivory cream surface background for cards and dialogs (0XFFE6DEC8) in Learning
  static const Color creamWarmLightE6dec8 = Color(0XFFE6DEC8);

  /// Warm ivory cream surface background for cards and dialogs (0XFFE9DFC4) in Dashboard
  static const Color creamWarmLightE9dfc4 = Color(0XFFE9DFC4);

  /// Warm ivory cream surface background for cards and dialogs (0XFFEAE0CA) in Attendance
  static const Color creamWarmLightEae0ca = Color(0XFFEAE0CA);

  /// Warm ivory cream surface background for cards and dialogs (0XFFEDE4CE) in Messaging
  static const Color creamWarmLightEde4ce = Color(0XFFEDE4CE);

  /// Warm ivory cream surface background for cards and dialogs (0XFFF0EAD8) in Fees
  static const Color creamWarmLightF0ead8 = Color(0XFFF0EAD8);

  /// Warm ivory cream surface background for cards and dialogs (0XFFF3E6C3) in Messaging
  static const Color creamWarmLightF3e6c3 = Color(0XFFF3E6C3);

  /// Warm ivory cream surface background for cards and dialogs (0XFFF3E6C6) in Dashboard
  static const Color creamWarmLightF3e6c6 = Color(0XFFF3E6C6);

  /// Soft sand neutral for cards, chips, and dividers (0XFFF5E6B8) in Progress
  static const Color sandWarmMutedF5e6b8 = Color(0XFFF5E6B8);

  /// Warm ivory cream surface background for cards and dialogs (0XFFF5ECD8) in Events
  static const Color creamWarmLightF5ecd8 = Color(0XFFF5ECD8);

  /// Warm ivory cream surface background for cards and dialogs (0XFFF5EFE0) in Fees
  static const Color creamWarmLightF5efe0 = Color(0XFFF5EFE0);

  /// Warm ivory cream surface background for cards and dialogs (0XFFF5F2EA) in Messaging
  static const Color creamWarmLightF5f2ea = Color(0XFFF5F2EA);

  /// Warm ivory cream surface background for cards and dialogs (0XFFF6F1E6) in Progress
  static const Color creamWarmLightF6f1e6 = Color(0XFFF6F1E6);

  /// Soft sand neutral for cards, chips, and dividers (0XFFF7DEA8) in Students, Directory
  static const Color sandWarmMutedF7dea8 = Color(0XFFF7DEA8);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFAF4E4) in Dashboard
  static const Color creamWarmLightFaf4e4 = Color(0XFFFAF4E4);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFAF5EA) in Events
  static const Color creamWarmLightFaf5ea = Color(0XFFFAF5EA);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFAF6EC) in Dashboard
  static const Color creamWarmLightFaf6ec = Color(0XFFFAF6EC);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFAF7EE) in Dashboard
  static const Color creamWarmLightFaf7ee = Color(0XFFFAF7EE);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFBF6EA) in Fees
  static const Color creamWarmLightFbf6ea = Color(0XFFFBF6EA);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFDEBD0) in Fees
  static const Color creamWarmLightFdebd0 = Color(0XFFFDEBD0);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFDF2DB) in Dashboard
  static const Color creamWarmLightFdf2db = Color(0XFFFDF2DB);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFDF5E6) in Core/Shared
  static const Color creamWarmLightFdf5e6 = Color(0XFFFDF5E6);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFDF8EB) in Auth
  static const Color creamWarmLightFdf8eb = Color(0XFFFDF8EB);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFDF8EC) in Events
  static const Color creamWarmLightFdf8ec = Color(0XFFFDF8EC);

  /// Warm ivory cream surface background for cards and dialogs (0XFFFDFBF7) in Learning
  static const Color creamWarmLightFdfbf7 = Color(0XFFFDFBF7);


  // ============================================================================
  // 5. SLATE & NEUTRAL TEXT TONES
  // High-contrast text, secondary labels, muted placeholders, and subtle borders.
  // ============================================================================

  /// Muted slate text for subtitles, dates, and secondary item information
  static const Color textMutedSlate = Color(0XFF3E4856);

  /// Neutral slate gray for secondary labels and descriptions
  static const Color textNeutralGray = Color(0XFF4B5563);

  /// Secondary slate text for metadata, labels, and timestamps
  static const Color textSecondarySlate = Color(0XFF4A5568);

  /// Cool gray text for hints and secondary icons
  static const Color textMutedCool = Color(0XFF6B7280);

  /// Slate unselected icon color
  static const Color slateUnselectedIcon = Color(0XFF525B6C);

  /// Dark slate gray for titles, text, and borders (0XFF2B1818) in Dashboard
  static const Color grayDark2b1818 = Color(0XFF2B1818);

  /// Dark slate gray for titles, text, and borders (0XFF555E6C) in Auth
  static const Color grayDark555e6c = Color(0XFF555E6C);

  /// Dark slate gray for titles, text, and borders (0XFF5A6270) in Messaging
  static const Color grayDark5a6270 = Color(0XFF5A6270);

  /// Dark slate gray for titles, text, and borders (0XFF5A6372) in Students, Directory
  static const Color grayDark5a6372 = Color(0XFF5A6372);

  /// Medium slate gray for secondary typography and subtle icons (0XFF646D7A) in Auth
  static const Color grayMedium646d7a = Color(0XFF646D7A);

  /// Medium slate gray for secondary typography and subtle icons (0XFF7A828E) in Messaging
  static const Color grayMedium7a828e = Color(0XFF7A828E);

  /// Medium slate gray for secondary typography and subtle icons (0XFF94A3B8) in Core/Shared
  static const Color grayMedium94a3b8 = Color(0XFF94A3B8);

  /// Medium slate gray for secondary typography and subtle icons (0XFF9CA3AF) in Learning
  static const Color grayMedium9ca3af = Color(0XFF9CA3AF);


  // ============================================================================
  // 6. STATUS, ATTENDANCE & FUNCTIONAL ALERTS
  // Emerald success / attendance present, crimson absent / fee due, warnings, and alerts.
  // ============================================================================

  /// Crimson red used for absent student tags, overdue badges, and errors
  static const Color crimsonAbsent = Color(0XFF942921);

  /// Forest emerald green for attendance present badges and success tags
  static const Color greenPresent = Color(0XFF1B6342);

  /// Light mint green background for present/success badges
  static const Color greenBadgeBg = Color(0XFFCBEAD8);

  /// Mint green pill background for active status indicators
  static const Color greenPillBg = Color(0XFFC7EBDD);

  /// Soft pale green background for confirmed items
  static const Color greenSoftBg = Color(0XFFD4EFE2);

  /// Dark emerald green for badge typography and check icons
  static const Color greenBadgeDark = Color(0XFF216E4E);

  /// Light blush pink background for fee due and alert banners
  static const Color crimsonDueBg = Color(0XFFFCE6E5);

  /// Blush red border for fee due and alert containers
  static const Color crimsonDueBorder = Color(0XFFF3B7B4);

  /// Soft rose border for fee due badges
  static const Color crimsonBadgeBorder = Color(0XFFF7C9C7);

  /// Soft rose-red background for error banners
  static const Color crimsonErrorBannerBg = Color(0XFFFDE8E8);

  /// Dark crimson text for fee due and error banners
  static const Color crimsonDarkText = Color(0XFF8B1A1A);

  /// Vibrant green checkmark icon
  static const Color greenCheckmark = Color(0XFF2FA35A);

  /// Emerald green icon color for verified and completed states
  static const Color greenSuccessIcon = Color(0XFF3FA66B);

  /// Cobalt blue accent for special learning indicators
  static const Color blueAccent = Color(0XFF2B6CB0);

  /// Burgundy red for logout buttons and danger actions
  static const Color burgundyLogout = Color(0XFF932738);

  /// Crimson red for absent toggle button and alerts
  static const Color crimsonAbsentButton = Color(0XFFA94444);

  /// Emerald green for active success indicators (0XFF1E825C) in Events
  static const Color greenEmerald1e825c = Color(0XFF1E825C);

  /// Deep forest green for text and active borders (0XFF1F4732) in Students, Directory
  static const Color greenDeep1f4732 = Color(0XFF1F4732);

  /// Emerald green for active success indicators (0XFF218854) in Learning
  static const Color greenEmerald218854 = Color(0XFF218854);

  /// Emerald green for active success indicators (0XFF238854) in Dashboard
  static const Color greenEmerald238854 = Color(0XFF238854);

  /// Emerald green for active success indicators (0XFF3E7B52) in Progress
  static const Color greenEmerald3e7b52 = Color(0XFF3E7B52);

  /// Emerald green for active success indicators (0XFF3E8E5A) in Dashboard
  static const Color greenEmerald3e8e5a = Color(0XFF3E8E5A);

  /// Emerald green for active success indicators (0XFF4D9460) in Dashboard
  static const Color greenEmerald4d9460 = Color(0XFF4D9460);

  /// Emerald green for active success indicators (0XFF6B8A47) in Progress
  static const Color greenEmerald6b8a47 = Color(0XFF6B8A47);

  /// Deep dark crimson for alert typography and borders (0XFF8C6B28) in Core/Shared
  static const Color crimsonDeep8c6b28 = Color(0XFF8C6B28);

  /// Deep dark crimson for alert typography and borders (0XFF8E1B1B) in Dashboard
  static const Color crimsonDeep8e1b1b = Color(0XFF8E1B1B);

  /// Deep dark crimson for alert typography and borders (0XFF9A6700) in Fees
  static const Color crimsonDeep9a6700 = Color(0XFF9A6700);

  /// Deep dark crimson for alert typography and borders (0XFF9B7120) in Auth
  static const Color crimsonDeep9b7120 = Color(0XFF9B7120);

  /// Deep dark crimson for alert typography and borders (0XFF9C7B38) in Core/Shared
  static const Color crimsonDeep9c7b38 = Color(0XFF9C7B38);

  /// Deep dark crimson for alert typography and borders (0XFFA64B38) in Events
  static const Color crimsonDeepA64b38 = Color(0XFFA64B38);

  /// Deep dark crimson for alert typography and borders (0XFFAD873E) in Core/Shared
  static const Color crimsonDeepAd873e = Color(0XFFAD873E);

  /// Deep dark crimson for alert typography and borders (0XFFB38E46) in Core/Shared
  static const Color crimsonDeepB38e46 = Color(0XFFB38E46);

  /// Alert crimson red for buttons and warnings (0XFFB58922) in Messaging
  static const Color crimsonAlertB58922 = Color(0XFFB58922);

  /// Alert crimson red for buttons and warnings (0XFFB88924) in Events
  static const Color crimsonAlertB88924 = Color(0XFFB88924);

  /// Alert crimson red for buttons and warnings (0XFFB88E35) in Auth
  static const Color crimsonAlertB88e35 = Color(0XFFB88E35);

  /// Alert crimson red for buttons and warnings (0XFFB8923A) in Progress
  static const Color crimsonAlertB8923a = Color(0XFFB8923A);

  /// Alert crimson red for buttons and warnings (0XFFC5A054) in Core/Shared
  static const Color crimsonAlertC5a054 = Color(0XFFC5A054);

  /// Alert crimson red for buttons and warnings (0XFFC97A63) in Events
  static const Color crimsonAlertC97a63 = Color(0XFFC97A63);

  /// Alert crimson red for buttons and warnings (0XFFCDA756) in Dashboard
  static const Color crimsonAlertCda756 = Color(0XFFCDA756);

  /// Alert crimson red for buttons and warnings (0XFFCFA84E) in Auth
  static const Color crimsonAlertCfa84e = Color(0XFFCFA84E);

  /// Alert crimson red for buttons and warnings (0XFFD6AE50) in Auth
  static const Color crimsonAlertD6ae50 = Color(0XFFD6AE50);

  /// Alert crimson red for buttons and warnings (0XFFD9534F) in Dashboard
  static const Color crimsonAlertD9534f = Color(0XFFD9534F);

  /// Alert crimson red for buttons and warnings (0XFFD97777) in Auth
  static const Color crimsonAlertD97777 = Color(0XFFD97777);

  /// Alert crimson red for buttons and warnings (0XFFDAB650) in Fees
  static const Color crimsonAlertDab650 = Color(0XFFDAB650);

  /// Alert crimson red for buttons and warnings (0XFFE5C467) in Profile
  static const Color crimsonAlertE5c467 = Color(0XFFE5C467);

  /// Alert crimson red for buttons and warnings (0XFFF5B7B1) in Core/Shared
  static const Color crimsonAlertF5b7b1 = Color(0XFFF5B7B1);

  /// Blush pink background for alerts and negative badges (0XFFF9D8D6) in Fees
  static const Color crimsonBlushF9d8d6 = Color(0XFFF9D8D6);

}
