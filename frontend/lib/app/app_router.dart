import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/parent_dashboard_screen.dart';
import '../../features/fees/presentation/screens/fee_management_screen.dart';
import '../../features/payments/presentation/screens/payment_submission_screen.dart';
import '../../features/fees/domain/models/monthly_fee_obligation.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/learning/presentation/screens/learning_module_screen.dart';
import '../../features/learning/presentation/screens/lesson_upload_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/messaging/presentation/screens/messaging_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/students/presentation/screens/students_list_screen.dart';
import '../../features/students/presentation/screens/student_form_screen.dart';
import '../../features/students/domain/models/student.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/fees/presentation/screens/fee_plan_form_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard/teacher',
      builder: (context, state) => const TeacherDashboardScreen(),
    ),
    GoRoute(
      path: '/dashboard/student',
      builder: (context, state) => const StudentDashboardScreen(),
    ),
    GoRoute(
      path: '/dashboard/parent',
      builder: (context, state) => const ParentDashboardScreen(),
    ),
    GoRoute(
      path: '/fees',
      builder: (context, state) => const FeeManagementScreen(),
    ),
    GoRoute(
      path: '/payments/submit',
      builder: (context, state) {
        final obligation = state.extra as MonthlyFeeObligation;
        return PaymentSubmissionScreen(obligation: obligation);
      },
    ),
    GoRoute(
      path: '/attendance',
      builder: (context, state) => const AttendanceScreen(),
    ),
    GoRoute(
      path: '/learning',
      builder: (context, state) => const LearningModuleScreen(),
    ),
    GoRoute(
      path: '/learning/upload',
      builder: (context, state) => const LessonUploadScreen(),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/messaging',
      builder: (context, state) => const MessagingScreen(),
    ),
    GoRoute(
      path: '/events',
      builder: (context, state) => const EventsScreen(),
    ),
    GoRoute(
      path: '/students',
      builder: (context, state) => const StudentsListScreen(),
    ),
    GoRoute(
      path: '/students/form',
      builder: (context, state) {
        final student = state.extra as Student?;
        return StudentFormScreen(student: student);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/fee-plans/form',
      builder: (context, state) {
        final plan = state.extra as Map<String, dynamic>?;
        return FeePlanFormScreen(feePlan: plan);
      },
    ),
  ],
);
