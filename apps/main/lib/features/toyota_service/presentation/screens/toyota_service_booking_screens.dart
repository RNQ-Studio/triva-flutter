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

part 'toyota_service_booking_customer.dart';
part 'toyota_service_booking_admin_queue.dart';
part 'toyota_service_booking_admin_detail.dart';
part 'toyota_service_booking_shared.dart';
