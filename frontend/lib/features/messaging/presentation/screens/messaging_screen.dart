import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../core/utils/app_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import '../../../../core/network/api_client.dart' as shri_nrityalaya_app_dio;
import '../../../auth/presentation/providers/auth_providers.dart'
    as shri_nrityalaya_app_auth;

final announcementsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(shri_nrityalaya_app_dio.dioProvider);
  final response = await dio.get('/announcements');
  return response.data['data'];
});

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  static const Color _navyHeader = AppColors.navySlate0e1f3d;
  static const Color _goldTitle = AppColors.goldTitleSoft;
  static const Color _goldAccent = AppColors.goldActionButton;
  static const Color _darkNavyText = AppColors.darkNavyText;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRelativeTime(dynamic rawDate) {
    if (rawDate == null) return '2 hours ago';
    final parsed = DateTime.tryParse(rawDate.toString());
    if (parsed == null) return '2 hours ago';
    final diff = DateTime.now().difference(parsed);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    final d = diff.inDays;
    if (d < 7) return '$d ${d == 1 ? 'day' : 'days'} ago';
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final announcementsState = ref.watch(announcementsProvider);
    final userRole = ref.watch(shri_nrityalaya_app_auth.authProvider).userRole;
    final isTeacherOrAdmin =
        userRole == 'Teacher' || userRole == 'SystemAdmin';

    return AppScaffold(
      body: Column(
        children: [
          // Deep Navy Header with Serif Title & Pill Search Bar
          Container(
            width: double.infinity,
            color: _navyHeader,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (context.canPop())
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.arrow_back,
                              color: _goldTitle,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    const Expanded(
                      child: Text(
                        'Announcements\n& Messages',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          color: _goldTitle,
                          height: 1.18,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
      
                // Search Pill Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.creamWarmLightF5f2ea,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppColors.textNeutralGray,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(
                            fontSize: 13.8,
                            color: _darkNavyText,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search announcements or students...',
                            hintStyle: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.grayMedium7a828e,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textMutedCool,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      
          // Announcements List Body
          Expanded(
            child: announcementsState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: _navyHeader),
              ),
              error: (err, stack) => ErrorView(
                error: err,
                onRetry: () => ref.refresh(announcementsProvider),
              ),
              data: (announcements) {
                final filtered = announcements.where((ann) {
                  if (_searchQuery.trim().isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  final title = (ann['title'] ?? '').toString().toLowerCase();
                  final content =
                      (ann['content'] ?? '').toString().toLowerCase();
                  return title.contains(q) || content.contains(q);
                }).toList();
      
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 52,
                          color: _navyHeader.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No announcements match your search.'
                              : 'No announcements yet.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textNeutralGray,
                          ),
                        ),
                      ],
                    ),
                  );
                }
      
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ann = filtered[index];
                    final title = (ann['title'] ?? 'No Title').toString();
                    final content = (ann['content'] ?? '').toString();
                    final timeAgo = _formatRelativeTime(
                      ann['createdAt'] ?? ann['created_at'] ?? ann['date'],
                    );
                    final roleBadge = (ann['senderRole'] ??
                            ann['authorRole'] ??
                            (index == 0 ? 'Admin' : 'Acharya'))
                        .toString();
                    final audienceBadge = (ann['targetAudience'] ??
                            ann['audience'] ??
                            (index == 0
                                ? 'All Students & Parents'
                                : 'Senior Batch Only'))
                        .toString();
      
                    return _buildAnnouncementCard(
                      title: title,
                      content: content,
                      timeAgo: timeAgo,
                      roleBadge: roleBadge,
                      audienceBadge: audienceBadge,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isTeacherOrAdmin
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _darkNavyText, width: 1.3),
                boxShadow: [
                  BoxShadow(
                    color: _navyHeader.withValues(alpha: 0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const _CreateAnnouncementSheet(),
                  );
                },
                backgroundColor: _goldAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                label: const Text(
                  'New Announcement',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String content,
    required String timeAgo,
    required String roleBadge,
    required String audienceBadge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Gold Accent Bar
            Container(
              width: 6,
              color: _goldAccent,
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular Gold Megaphone Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.creamWarmLightF3e6c3,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.campaign_outlined,
                            color: AppColors.crimsonAlertB58922,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title, Excerpt & Timestamp
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: _darkNavyText,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDarkSlate,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                timeAgo,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grayDark5a6270,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),

                    // Bottom Pills Row: Role Badge + Target Audience Badge
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sandWarmMutedD5d9e0,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            roleBadge,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navySlate1e293b,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.creamWarmLightEde4ce,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            audienceBadge,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navySlate1e293b,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAnnouncementSheet extends ConsumerStatefulWidget {
  const _CreateAnnouncementSheet();

  @override
  ConsumerState<_CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState
    extends ConsumerState<_CreateAnnouncementSheet> {
  static const Color _sheetCream = AppColors.creamSheetBackground;
  static const Color _fieldCream = AppColors.creamFieldBackground;
  static const Color _darkNavyBorder = AppColors.navyDarkBorder;
  static const Color _darkNavyText = AppColors.darkNavyText;
  static const Color _goldTitleBrown = AppColors.goldTitleBrown;
  static const Color _goldHint = AppColors.goldHintText;
  static const Color _goldButton = AppColors.goldActionButton;

  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _selectedAudience = 'Select Students/Batches';
  bool _isLoading = false;

  final List<String> _audienceOptions = const [
    'Select Students/Batches',
    'All Students & Parents',
    'Senior Batch Only',
    'Junior Batch Only',
    'All Batches',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(shri_nrityalaya_app_dio.dioProvider);
      await dio.post('/announcements', data: {
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
      });
      ref.invalidate(announcementsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _sheetCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 22,
        right: 22,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Gold Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.goldOchreIcon,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Sheet Header: "New Announcement"
            const Center(
              child: Text(
                'New Announcement',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _goldTitleBrown,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Field 1: Announcement Title
            const Text(
              'Announcement Title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _darkNavyText,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(
                fontSize: 14.5,
                color: _darkNavyText,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Announcement Title',
                hintStyle: const TextStyle(
                  color: _goldHint,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: _fieldCream,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _darkNavyBorder, width: 1.3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _darkNavyBorder, width: 1.3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _darkNavyBorder, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Field 2: Message Body
            const Text(
              'Message Body',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _darkNavyText,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              maxLines: 5,
              style: const TextStyle(
                fontSize: 14.5,
                color: _darkNavyText,
              ),
              decoration: InputDecoration(
                hintText: 'Message Body',
                hintStyle: const TextStyle(
                  color: _goldHint,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: _fieldCream,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _darkNavyBorder, width: 1.3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _darkNavyBorder, width: 1.3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _darkNavyBorder, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Field 3: Target Audience Dropdown
            const Text(
              'Target Audience',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _darkNavyText,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedAudience,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _goldTitleBrown,
                size: 22,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _goldTitleBrown,
              ),
              dropdownColor: _sheetCream,
              decoration: InputDecoration(
                filled: true,
                fillColor: _fieldCream,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.goldOchreIcon,
                    width: 1.3,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.goldOchreIcon,
                    width: 1.3,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: _goldTitleBrown,
                    width: 1.6,
                  ),
                ),
              ),
              items: _audienceOptions
                  .map(
                    (opt) => DropdownMenuItem<String>(
                      value: opt,
                      child: Text(opt),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedAudience = val);
                }
              },
            ),
            const SizedBox(height: 24),

            // Submit Button: "Post Announcement" with Paper Plane Icon
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _goldButton,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _isLoading ? null : _post,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Post Announcement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.near_me_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
