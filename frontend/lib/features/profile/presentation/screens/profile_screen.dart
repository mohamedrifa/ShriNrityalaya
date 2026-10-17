import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _goldBright = AppColors.goldBright;
  static const Color _goldPrimary = AppColors.goldBorder;
  static const Color _darkNavyText = AppColors.darkNavyText;
  static const Color _cardBorderNavy = AppColors.navyCardBorder;
  static const Color _creamBg = AppColors.creamPageBgWarm;
  static const Color _burgundyLogout = AppColors.burgundyLogout;

  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isNameUpdating = false;
  bool _isPasswordUpdating = false;
  bool _isImageUploading = false;
  bool _hasLoadedInitialData = false;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _isImageUploading = true);
      try {
        await ref
            .read(profileProvider.notifier)
            .uploadProfileImage(result.files.single.path!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
          );
        }
      } finally {
        if (mounted) setState(() => _isImageUploading = false);
      }
    }
  }

  Future<void> _updateName() async {
    if (!_nameFormKey.currentState!.validate()) return;
    setState(() => _isNameUpdating = true);
    try {
      final rawName = _fullNameController.text.trim();
      final parts = rawName.split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName =
          parts.length > 1 ? parts.sublist(1).join(' ') : '';

      await ref.read(profileProvider.notifier).updateProfile(
            firstName,
            lastName,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isNameUpdating = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isPasswordUpdating = true);
    try {
      await ref.read(profileProvider.notifier).changePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isPasswordUpdating = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(secureStorageProvider).delete(key: 'jwt_token');
    ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textNeutralGray,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.creamInputFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.sandWarmMutedD1cfc9, width: 1.1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.sandWarmMutedD1cfc9, width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _navyHeader, width: 1.5),
      ),
    );
  }

  String _roleBadgeLabel(String? role) {
    final r = (role ?? 'User').trim();
    if (r.toLowerCase() == 'teacher') {
      return 'ACHARYA / TEACHER';
    }
    if (r.toLowerCase() == 'systemadmin') {
      return 'SYSTEM ADMIN';
    }
    return r.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: _navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 60,
        leadingWidth: 64,
        leading: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyAccentDark,
                border: Border.all(
                  color: AppColors.navyGradientMid,
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: _goldBright,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _goldBright,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: _goldBright,
                size: 23,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ColoredBox(
        color: _creamBg,
        child: profileState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _navyHeader),
          ),
          error: (err, stack) => ErrorView(
            error: err,
            onRetry: () => ref.refresh(profileProvider),
          ),
          data: (profile) {
            final firstName = (profile['firstName'] ?? '').toString().trim();
            final lastName = (profile['lastName'] ?? '').toString().trim();
            final combinedName = '$firstName $lastName'.trim();

            if (!_hasLoadedInitialData) {
              _fullNameController.text = combinedName;
              _phoneController.text =
                  (profile['phoneNumber'] ?? profile['phone'] ?? '+91 98765 43210')
                      .toString();
              _hasLoadedInitialData = true;
            }

            final imageUrl = profile['profilePictureUrl'] as String?;
            final baseUrl = ref
                .read(dioProvider)
                .options
                .baseUrl
                .replaceAll('/api/v1', '');
            final hasNetworkImage = imageUrl != null && imageUrl.isNotEmpty;

            return SingleChildScrollView(
              child: Stack(
                children: [
                  // Curved Deep-Navy Top Extension Behind Hero Card
                  Container(
                    height: 112,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _navyHeader,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                    child: Column(
                      children: [
                        // 1. Hero Profile Card with Mandala Halo & Gold Border
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          decoration: BoxDecoration(
                            gradient: const RadialGradient(
                              center: Alignment(0, -0.25),
                              radius: 0.95,
                              colors: [
                                AppColors.navyRoyal243f73,
                                AppColors.navySlate132548,
                                AppColors.navyMidnight0b162c,
                              ],
                              stops: [0.0, 0.62, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _goldPrimary,
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _navyHeader.withValues(alpha: 0.28),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Ornate Mandala Halo + Avatar + Camera Badge
                              GestureDetector(
                                onTap: _isImageUploading
                                    ? null
                                    : _pickAndUploadImage,
                                child: SizedBox(
                                  width: 132,
                                  height: 132,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Soft Golden Glow
                                      Container(
                                        width: 114,
                                        height: 114,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _goldBright
                                                  .withValues(alpha: 0.30),
                                              blurRadius: 24,
                                              spreadRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Intricate Gold Mandala Halo Painter
                                      const CustomPaint(
                                        size: Size(130, 130),
                                        painter: _MandalaHaloPainter(),
                                      ),
                                      // Profile Picture Circle
                                      Container(
                                        width: 84,
                                        height: 84,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _navyHeader,
                                          border: Border.all(
                                            color: _goldBright,
                                            width: 2.2,
                                          ),
                                          image: hasNetworkImage
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    '$baseUrl$imageUrl',
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: _isImageUploading
                                            ? const Center(
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    color: _goldBright,
                                                  ),
                                                ),
                                              )
                                            : (!hasNetworkImage
                                                ? const Icon(
                                                    Icons.person,
                                                    size: 44,
                                                    color: _goldBright,
                                                  )
                                                : null),
                                      ),
                                      // Bottom-Right Gold Camera Badge
                                      Positioned(
                                        bottom: 14,
                                        right: 16,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _goldPrimary,
                                            border: Border.all(
                                              color: _darkNavyText,
                                              width: 1.4,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 16,
                                            color: _darkNavyText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Full Name
                              Text(
                                combinedName.isEmpty
                                    ? (profile['userName'] ?? 'User').toString()
                                    : combinedName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: _goldBright,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Gold Role Pill ("ACHARYA / TEACHER")
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4.5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.crimsonAlertE5c467,
                                      AppColors.goldPrimaryAmber,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _roleBadgeLabel(profile['role']?.toString()),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: _darkNavyText,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Email / Username
                              Text(
                                (profile['email'] ??
                                        profile['userName'] ??
                                        '')
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 12.8,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 2. Unified White Card: Personal Information + Security & Login
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _cardBorderNavy,
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _navyHeader.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Top-Right Gold Lotus Ornament
                              const Positioned(
                                top: 10,
                                right: 12,
                                child: _CornerLotusOrnament(size: 28),
                              ),
                              // Bottom-Left Gold Lotus Ornament
                              const Positioned(
                                bottom: 10,
                                left: 12,
                                child: _CornerLotusOrnament(size: 28),
                              ),
                              // Bottom-Right Gold Lotus Ornament
                              const Positioned(
                                bottom: 10,
                                right: 12,
                                child: _CornerLotusOrnament(size: 28),
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 18, 18, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Personal Information Form
                                    Form(
                                      key: _nameFormKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Personal Information',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: _darkNavyText,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          TextFormField(
                                            controller: _fullNameController,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: _darkNavyText,
                                            ),
                                            decoration: _inputDecoration(
                                              label: 'Full Name',
                                            ),
                                            validator: (v) =>
                                                v == null || v.trim().isEmpty
                                                    ? 'Required'
                                                    : null,
                                          ),
                                          const SizedBox(height: 14),
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 14,
                                                ),
                                                child: TextFormField(
                                                  controller: _phoneController,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: _darkNavyText,
                                                  ),
                                                  decoration: _inputDecoration(
                                                    label: 'Phone Number',
                                                  ),
                                                ),
                                              ),
                                              // Overlapping Bottom-Right "Update Info" Pill Button
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: SizedBox(
                                                  height: 32,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          _navyHeader,
                                                      foregroundColor:
                                                          _goldBright,
                                                      elevation: 1,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 14,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18),
                                                        side: const BorderSide(
                                                          color: _goldPrimary,
                                                          width: 1.2,
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: _isNameUpdating
                                                        ? null
                                                        : _updateName,
                                                    child: _isNameUpdating
                                                        ? const SizedBox(
                                                            width: 14,
                                                            height: 14,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  _goldBright,
                                                            ),
                                                          )
                                                        : const Text(
                                                            'Update Info',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  _goldBright,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Security & Login Form
                                    Form(
                                      key: _passwordFormKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Security & Login',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: _darkNavyText,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          TextFormField(
                                            controller:
                                                _currentPasswordController,
                                            obscureText:
                                                _obscureCurrentPassword,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: _darkNavyText,
                                            ),
                                            decoration: _inputDecoration(
                                              label: 'Current Password',
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureCurrentPassword
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  size: 19,
                                                  color:
                                                      AppColors.textMutedCool,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureCurrentPassword =
                                                        !_obscureCurrentPassword;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Required'
                                                    : null,
                                          ),
                                          const SizedBox(height: 14),
                                          TextFormField(
                                            controller: _newPasswordController,
                                            obscureText: _obscureNewPassword,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: _darkNavyText,
                                            ),
                                            decoration: _inputDecoration(
                                              label: 'New Password',
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureNewPassword
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  size: 19,
                                                  color:
                                                      AppColors.textMutedCool,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureNewPassword =
                                                        !_obscureNewPassword;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Required'
                                                    : null,
                                          ),
                                          const SizedBox(height: 16),

                                          // Centered "Change Password" Pill Button
                                          Center(
                                            child: SizedBox(
                                              height: 38,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _navyHeader,
                                                  foregroundColor: _goldBright,
                                                  elevation: 1,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 26,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      22,
                                                    ),
                                                    side: const BorderSide(
                                                      color: _goldPrimary,
                                                      width: 1.3,
                                                    ),
                                                  ),
                                                ),
                                                onPressed: _isPasswordUpdating
                                                    ? null
                                                    : _changePassword,
                                                child: _isPasswordUpdating
                                                    ? const SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: _goldBright,
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Change Password',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: _goldBright,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 3. Full-Width "Logout" Stadium Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.creamSettingsTile,
                              foregroundColor: _burgundyLogout,
                              side: const BorderSide(
                                color: _burgundyLogout,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: _logout,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _burgundyLogout,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.logout_rounded,
                                  size: 17,
                                  color: _burgundyLogout,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

/// Ornate concentric gold mandala halo ring around the profile avatar.
class _MandalaHaloPainter extends CustomPainter {
  const _MandalaHaloPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 2;
    final innerR = 45.0;

    final goldStroke = Paint()
      ..color = AppColors.goldBorder.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final brightGoldStroke = Paint()
      ..color = AppColors.goldBright.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Outer scalloped ring & concentric circles
    canvas.drawCircle(center, outerR, goldStroke);
    canvas.drawCircle(center, outerR - 5, brightGoldStroke);
    canvas.drawCircle(center, innerR + 4, goldStroke);

    // 16 lotus petals radiating between innerR and outerR - 5
    const petalCount = 16;
    for (int i = 0; i < petalCount; i++) {
      final baseAngle = (2 * math.pi * i) / petalCount;
      final halfSpan = math.pi / petalCount;

      final pStart = Offset(
        center.dx + (innerR + 4) * math.cos(baseAngle - halfSpan * 0.8),
        center.dy + (innerR + 4) * math.sin(baseAngle - halfSpan * 0.8),
      );
      final pTip = Offset(
        center.dx + (outerR - 5) * math.cos(baseAngle),
        center.dy + (outerR - 5) * math.sin(baseAngle),
      );
      final pEnd = Offset(
        center.dx + (innerR + 4) * math.cos(baseAngle + halfSpan * 0.8),
        center.dy + (innerR + 4) * math.sin(baseAngle + halfSpan * 0.8),
      );
      final ctrl1 = Offset(
        center.dx + (outerR - 9) * math.cos(baseAngle - halfSpan * 0.55),
        center.dy + (outerR - 9) * math.sin(baseAngle - halfSpan * 0.55),
      );
      final ctrl2 = Offset(
        center.dx + (outerR - 9) * math.cos(baseAngle + halfSpan * 0.55),
        center.dy + (outerR - 9) * math.sin(baseAngle + halfSpan * 0.55),
      );

      final path = Path()
        ..moveTo(pStart.dx, pStart.dy)
        ..quadraticBezierTo(ctrl1.dx, ctrl1.dy, pTip.dx, pTip.dy)
        ..quadraticBezierTo(ctrl2.dx, ctrl2.dy, pEnd.dx, pEnd.dy);
      canvas.drawPath(path, goldStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Delicate gold lotus line-art corner ornament for the white settings card.
class _CornerLotusOrnament extends StatelessWidget {
  final double size;
  const _CornerLotusOrnament({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.78),
      painter: _CornerLotusPainter(),
    );
  }
}

class _CornerLotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldBorder.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.5;
    final cy = size.height * 0.82;

    final centerPetal = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx - size.width * 0.18,
        cy - size.height * 0.45,
        cx,
        cy - size.height * 0.72,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.18,
        cy - size.height * 0.45,
        cx,
        cy,
      );
    canvas.drawPath(centerPetal, paint);

    final leftPetal = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx - size.width * 0.36,
        cy - size.height * 0.35,
        cx - size.width * 0.32,
        cy - size.height * 0.54,
      )
      ..quadraticBezierTo(
        cx - size.width * 0.10,
        cy - size.height * 0.40,
        cx,
        cy,
      );
    canvas.drawPath(leftPetal, paint);

    final rightPetal = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx + size.width * 0.36,
        cy - size.height * 0.35,
        cx + size.width * 0.32,
        cy - size.height * 0.54,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.10,
        cy - size.height * 0.40,
        cx,
        cy,
      );
    canvas.drawPath(rightPetal, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
