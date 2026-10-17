import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────
class AcharyaColors {
  static const Color pageBackground   = AppColors.creamPageBackground;
  static const Color screenBackground = AppColors.creamScreenBackground;
  static const Color navy             = AppColors.navyAcharya;
  static const Color navyDeep         = AppColors.navyDeepAcharya;
  static const Color gold             = AppColors.goldMetallic;
  static const Color goldLight        = AppColors.goldLightAccent;
  static const Color goldPale         = AppColors.goldPaleChip;
  static const Color cardBorder       = AppColors.navyBorderSlate;
  static const Color cardFill         = AppColors.pureWhite;
  static const Color textPrimary      = AppColors.textDarkPrimary;
  static const Color textSecondary    = AppColors.textSecondarySlate;
  static const Color navInactive      = AppColors.navyNavInactive;
  static const Color checkGreen       = AppColors.greenSuccessIcon;
  static const Color cream            = AppColors.creamWarmIvory;
}

// ─── Text styles ─────────────────────────────────────────────────────────────
class AcharyaTextStyles {
  static TextStyle brand = GoogleFonts.cinzel(
    fontWeight: FontWeight.w600, fontSize: 12.5,
    letterSpacing: 0.6, color: AcharyaColors.navy,
  );
  static TextStyle greeting = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w800, fontSize: 24,
    height: 1.15, color: AcharyaColors.goldLight,
  );
  static TextStyle subtitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w400, fontSize: 13, color: Colors.white,
  );
  static TextStyle rosterLabel = GoogleFonts.poppins(
    fontWeight: FontWeight.w500, fontSize: 13, color: Colors.white,
  );
  static TextStyle cardTitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w700, fontSize: 14,
    letterSpacing: 0, color: AcharyaColors.textPrimary,
  );
  static TextStyle cardBody = GoogleFonts.poppins(
    fontWeight: FontWeight.w400, fontSize: 12,
    height: 1.3, color: AcharyaColors.textSecondary,
  );
  static TextStyle cardLink = GoogleFonts.poppins(
    fontWeight: FontWeight.w600, fontSize: 12.5,
    color: AcharyaColors.textPrimary,
  );
  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w700, fontSize: 15,
    letterSpacing: 0.8, color: AcharyaColors.textPrimary,
  );
  static TextStyle eventDateNumber = GoogleFonts.poppins(
    fontWeight: FontWeight.w700, fontSize: 20,
    color: AcharyaColors.textPrimary,
  );
  static TextStyle eventDateMonth = GoogleFonts.poppins(
    fontWeight: FontWeight.w400, fontSize: 13,
    color: AcharyaColors.textSecondary,
  );
  static TextStyle eventTitle = GoogleFonts.poppins(
    fontWeight: FontWeight.w500, fontSize: 14,
    color: AcharyaColors.textPrimary,
  );
  static TextStyle pillLabel = GoogleFonts.poppins(
    fontWeight: FontWeight.w500, fontSize: 10.5,
    letterSpacing: 0.4, color: AcharyaColors.gold,
  );
  static TextStyle bottomNavLabel = GoogleFonts.poppins(
    fontWeight: FontWeight.w500, fontSize: 12,
  );
  static TextStyle avatarInitials = GoogleFonts.poppins(
    fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white,
  );
  static TextStyle avatarCaption = GoogleFonts.poppins(
    fontWeight: FontWeight.w600, fontSize: 8, color: AcharyaColors.navy,
  );
}

// ─── HEADER BAR ──────────────────────────────────────────────────────────────
class AcharyaHeaderBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final Widget? profileAvatar;
  final VoidCallback? onProfileTap;

  const AcharyaHeaderBar({
    super.key,
    required this.onMenuTap,
    this.profileAvatar,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 82,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Solid navy circular hamburger menu button
              GestureDetector(
                onTap: onMenuTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AcharyaColors.navy,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),

              // Center: Horizontal Crescent Logo + Left-Aligned 2-Line Brand Name
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_crescent.png',
                      height: 42,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.circle_outlined,
                        color: AcharyaColors.navy,
                        size: 42,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'BHARATANATYAM\nACADEMY',
                        textAlign: TextAlign.left,
                        style: AcharyaTextStyles.brand.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: 0.5,
                          color: AcharyaColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Double-Ringed User Profile Avatar from API
              GestureDetector(
                onTap: onProfileTap,
                behavior: HitTestBehavior.opaque,
                child: profileAvatar ??
                    Container(
                      padding: const EdgeInsets.all(2.2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AcharyaColors.screenBackground,
                        border: Border.all(
                          color: AcharyaColors.navy,
                          width: 2.2,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AcharyaColors.navy,
                            width: 1.6,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: AcharyaColors.navy,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PROGRESS ROW ─────────────────────────────────────────────────────────────
class _ProgressRow extends StatelessWidget {
  final String label;
  final double fill;
  final bool isGold;
  final bool showCheck;

  const _ProgressRow({
    required this.label,
    required this.fill,
    this.isGold = false,
    this.showCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AcharyaTextStyles.rosterLabel),
            if (showCheck) Row(children: [
              const Icon(Icons.check, color: AcharyaColors.checkGreen, size: 13),
              const SizedBox(width: 4),
              Text('...ed',
                style: AcharyaTextStyles.rosterLabel.copyWith(
                  color: Colors.white54, fontSize: 11,
                )),
            ]),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fill,
              child: Container(
                decoration: BoxDecoration(
                  color: isGold ? AcharyaColors.gold : Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── GLASS CARD ───────────────────────────────────────────────────────────────
class AcharyaGlassCard extends StatelessWidget {
  final String username;

  const AcharyaGlassCard({super.key, this.username = 'Teacher'});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.92, 1.0],
        colors: [Colors.black, Colors.black, Colors.transparent],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.navyAcharya.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AcharyaColors.gold.withValues(alpha: 0.30), width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Namaskaram,\n$username!', style: AcharyaTextStyles.greeting),
            const SizedBox(height: 5),
            Text('Guide the next generation of mastery',
              style: AcharyaTextStyles.subtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const _ProgressRow(
              label: 'View Class Roster', fill: 0.25,
            ),
            const SizedBox(height: 8),
            const _ProgressRow(
              label: 'Grade Adavus - Part 1', fill: 0.60,
              isGold: true, showCheck: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HERO BANNER ──────────────────────────────────────────────────────────────
class AcharyaHeroBanner extends StatelessWidget {
  final String username;

  const AcharyaHeroBanner({super.key, this.username = 'Teacher'});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final bannerH = sw * (417 / 456);
    final cardW   = sw * (297 / 456);
    final cardL   = sw * (26 / 456);

    return SizedBox(
      height: bannerH,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Layer 1: clean background (floor + window, dancer removed)
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_clean_bg.png',
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/hero_full.png', fit: BoxFit.fill),
            ),
          ),

          // Layer 2: Glass card — no fixed height, let content size itself
          Positioned(
            left: cardL, top: 0,
            width: cardW,
            child: AcharyaGlassCard(username: username),
          ),

          // Layer 3 (TOP): dancer cutout, anchored bottom-right
          Positioned(
            right: 0, bottom: 0, top: 0,
            child: Image.asset(
              'assets/images/dancer_cutout.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/avatar_dancer_cutout.png',
                fit: BoxFit.contain, alignment: Alignment.bottomRight,
              ),
            ),
          ),

          // Bottom fade to screenBackground
          Positioned(
            bottom: 0, left: 0, right: 0, height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    AcharyaColors.screenBackground.withValues(alpha: 0.0),
                    AcharyaColors.screenBackground,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACTION CARD ──────────────────────────────────────────────────────────────
class AcharyaActionCard extends StatelessWidget {
  final String title;
  final String body;
  final String linkText;
  final IconData linkIcon;
  final VoidCallback? onTap;

  const AcharyaActionCard({
    super.key,
    required this.title,
    required this.body,
    required this.linkText,
    required this.linkIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 178,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AcharyaColors.cardFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AcharyaColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text(title, style: AcharyaTextStyles.cardTitle,
                maxLines: 1),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(body, style: AcharyaTextStyles.cardBody,
                maxLines: 4, overflow: TextOverflow.ellipsis),
            ),
            const Divider(color: AppColors.sandBorderSoft, height: 12, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(linkText, style: AcharyaTextStyles.cardLink,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                    color: AcharyaColors.gold, shape: BoxShape.circle,
                  ),
                  child: Icon(linkIcon, color: Colors.white, size: 17),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── EVENT TILE ───────────────────────────────────────────────────────────────
class AcharyaEventTile extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String pill;

  const AcharyaEventTile({
    super.key,
    required this.day,
    required this.month,
    required this.title,
    required this.pill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AcharyaColors.cardFill,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Date block
            SizedBox(
              width: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(day,   style: AcharyaTextStyles.eventDateNumber),
                  Text(month, style: AcharyaTextStyles.eventDateMonth),
                ],
              ),
            ),
            // Divider
            Container(width: 1, height: 40, color: AppColors.sandBorderSoft),
            // Title
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(title, style: AcharyaTextStyles.eventTitle,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
            // Pill
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AcharyaColors.cream,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AcharyaColors.gold, width: 1),
                ),
                child: Text(pill, style: AcharyaTextStyles.pillLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BOTTOM NAV ───────────────────────────────────────────────────────────────
class AcharyaBottomNavBar extends StatefulWidget {
  const AcharyaBottomNavBar({super.key});

  @override
  State<AcharyaBottomNavBar> createState() => _AcharyaBottomNavBarState();
}

class _AcharyaBottomNavBarState extends State<AcharyaBottomNavBar> {
  int _selected = 0;

  static const _labels = ['Home', 'Classes', 'Lessons', 'Feedback', 'Settings'];
  static const _icons  = [
    Icons.person_outline,
    Icons.groups_outlined,
    Icons.menu_book_outlined,
    Icons.chat_bubble_outline,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AcharyaColors.screenBackground.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10, offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (i) => _buildItem(i)),
      ),
    );
  }

  Widget _buildItem(int i) {
    final active = i == _selected;
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      behavior: HitTestBehavior.opaque,
      child: active
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AcharyaColors.goldPale,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AcharyaColors.gold, width: 2),
                    ),
                    child: Icon(_icons[i], color: AcharyaColors.navy, size: 22),
                  ),
                  const SizedBox(height: 2),
                  Text(_labels[i],
                    style: AcharyaTextStyles.bottomNavLabel.copyWith(
                      color: AcharyaColors.navy, fontWeight: FontWeight.bold,
                    )),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icons[i], color: AcharyaColors.navInactive, size: 24),
                  const SizedBox(height: 2),
                  Text(_labels[i],
                    style: AcharyaTextStyles.bottomNavLabel.copyWith(
                      color: AcharyaColors.navInactive,
                    )),
                ],
              ),
            ),
    );
  }
}

// ─── MAIN SCREEN ──────────────────────────────────────────────────────────────
class AcharyaDashboardScreen extends StatelessWidget {
  const AcharyaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AcharyaColors.pageBackground,
      body: Stack(
        children: [
          // Left temple BG (decorative, behind content on wide screens)
          Positioned(
            left: 0, bottom: 0,
            width: MediaQuery.of(context).size.width * 0.35,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset('assets/images/temple_left.png',
                fit: BoxFit.fitWidth, alignment: Alignment.bottomLeft,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            right: 0, bottom: 0,
            width: MediaQuery.of(context).size.width * 0.35,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset('assets/images/temple_right.png',
                fit: BoxFit.fitWidth, alignment: Alignment.bottomRight,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Phone surface
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: const BoxDecoration(
                color: AcharyaColors.screenBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  AcharyaHeaderBar(
                    onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                  ),

                  // Scrollable body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero banner
                          const AcharyaHeroBanner(),

                          // Action cards
                          // SizedBox(
                          //   height: 158,
                          //   child: ListView(
                          //     scrollDirection: Axis.horizontal,
                          //     padding: const EdgeInsets.only(left: 16),
                          //     children: const [
                          //       AcharyaActionCard(
                          //         title: 'MY CLASSES',
                          //         body: 'Manage student lists and attendance. 3 Classes Active.',
                          //         linkText: 'Manage Classes',
                          //         linkIcon: Icons.chevron_right,
                          //       ),
                          //       AcharyaActionCard(
                          //         title: 'CURRICULUM REVIEW',
                          //         body: 'Approve student submissions for Alarippu and Jatiswaram.',
                          //         linkText: 'Review Submissions',
                          //         linkIcon: Icons.check,
                          //       ),
                          //       AcharyaActionCard(
                          //         title: 'STUDENT PROGRESS',
                          //         body: 'Track progress and share feedback.',
                          //         linkText: 'Review Progress',
                          //         linkIcon: Icons.chevron_right,
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          // Upcoming Events
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 14),
                            child: Text('UPCOMING EVENTS',
                              style: AcharyaTextStyles.sectionTitle),
                          ),

                          const AcharyaEventTile(
                            day: '25', month: 'Jan',
                            title: 'Nattuvangam Workshop (Online)',
                            pill: 'FACILITATE',
                          ),
                          const AcharyaEventTile(
                            day: '29', month: 'Dec',
                            title: 'Term Review Committee',
                            pill: 'CONFIRM ATTENDANCE',
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom nav
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: const AcharyaBottomNavBar(),
          ),
        ],
      ),
    );
  }
}
