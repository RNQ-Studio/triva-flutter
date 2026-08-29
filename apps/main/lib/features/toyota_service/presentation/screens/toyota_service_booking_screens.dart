import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_shared/features_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/toyota_service_models.dart';
import '../toyota_service_controller.dart';
import '../toyota_service_paths.dart';
import '../widgets/toyota_service_widgets.dart';
import '../../../otoxpert/presentation/otoxpert_paths.dart';
import '../../../body_paint/presentation/body_paint_paths.dart';
import '../../../admin_directory/presentation/admin_directory_paths.dart';
import '../../../admin_users/presentation/admin_user_paths.dart';
import '../../../visit_analytics/presentation/admin_demographics_section.dart';
import '../../../visit_analytics/presentation/admin_menu_usage_section.dart';
import '../../../visit_analytics/presentation/admin_visit_dashboard_section.dart';
import '../../../visit_analytics/presentation/visit_analytics_controller.dart';

part 'toyota_service_booking_customer.dart';
part 'toyota_service_booking_admin_queue.dart';
part 'toyota_service_booking_admin_detail.dart';
part 'toyota_service_booking_shared.dart';
