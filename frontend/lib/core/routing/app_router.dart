import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/student_attendance_tracker_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/parent_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/directory/presentation/screens/directory_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/fees/domain/models/monthly_fee_obligation.dart';
import '../../features/fees/presentation/screens/fee_management_screen.dart';
import '../../features/fees/presentation/screens/fee_plan_form_screen.dart';
import '../../features/learning/domain/models/lesson.dart';
import '../../features/learning/presentation/screens/learning_module_screen.dart';
import '../../features/learning/presentation/screens/lesson_player_screen.dart';
import '../../features/learning/presentation/screens/lesson_upload_screen.dart';
import '../../features/messaging/presentation/screens/messaging_screen.dart';
import '../../features/payments/presentation/screens/payment_details_screen.dart';
import '../../features/payments/presentation/screens/payment_submission_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/students/domain/models/student.dart';
import '../../features/students/presentation/screens/student_form_screen.dart';
import '../../features/students/presentation/screens/students_list_screen.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.teacherDashboard,
      builder: (context, state) => const TeacherDashboardScreen(),
    ),
    GoRoute(
      path: RouteNames.studentDashboard,
      builder: (context, state) => const StudentDashboardScreen(),
    ),
    GoRoute(
      path: RouteNames.parentDashboard,
      builder: (context, state) => const ParentDashboardScreen(),
    ),
    GoRoute(
      path: RouteNames.fees,
      builder: (context, state) => const FeeManagementScreen(),
    ),
    GoRoute(
      path: RouteNames.paymentSubmit,
      builder: (context, state) {
        final obligation = state.extra as MonthlyFeeObligation;
        return PaymentSubmissionScreen(obligation: obligation);
      },
    ),
    GoRoute(
      path: RouteNames.paymentDetails,
      builder: (context, state) {
        final obligation = state.extra as MonthlyFeeObligation;
        return PaymentDetailsScreen(obligation: obligation);
      },
    ),
    GoRoute(
      path: RouteNames.attendance,
      builder: (context, state) => const AttendanceScreen(),
    ),
    GoRoute(
      path: RouteNames.studentAttendance,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return StudentAttendanceTrackerScreen(
          studentId: extra?['studentId'] as String?,
          studentName: extra?['studentName'] as String?,
        );
      },
    ),
    GoRoute(
      path: RouteNames.learning,
      builder: (context, state) => const LearningModuleScreen(),
    ),
    GoRoute(
      path: RouteNames.learningPlay,
      builder: (context, state) {
        final lesson = state.extra as Lesson;
        return LessonPlayerScreen(lesson: lesson);
      },
    ),
    GoRoute(
      path: RouteNames.learningUpload,
      builder: (context, state) => const LessonUploadScreen(),
    ),
    GoRoute(
      path: RouteNames.progress,
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: RouteNames.messaging,
      builder: (context, state) => const MessagingScreen(),
    ),
    GoRoute(
      path: RouteNames.events,
      builder: (context, state) => const EventsScreen(),
    ),
    GoRoute(
      path: RouteNames.students,
      builder: (context, state) => const StudentsListScreen(),
    ),
    GoRoute(
      path: RouteNames.studentForm,
      builder: (context, state) {
        final student = state.extra as Student?;
        return StudentFormScreen(student: student);
      },
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.feePlanForm,
      builder: (context, state) {
        final plan = state.extra as Map<String, dynamic>?;
        return FeePlanFormScreen(feePlan: plan);
      },
    ),
    GoRoute(
      path: RouteNames.directory,
      builder: (context, state) => const DirectoryScreen(),
    ),
  ],
);
