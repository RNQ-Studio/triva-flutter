import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:features_shared/features_shared.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../domain/toyota_service_models.dart';
import '../../../otoxpert/presentation/otoxpert_paths.dart';
import '../toyota_service_controller.dart';
import '../toyota_service_paths.dart';
import '../widgets/toyota_service_widgets.dart';
import '../widgets/ths_location_picker.dart';

part 'toyota_service_intake_vehicle.dart';
part 'toyota_service_intake_selection.dart';
part 'toyota_service_intake_request.dart';
part 'toyota_service_intake_address_review.dart';
