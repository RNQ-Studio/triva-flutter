import '../domain/toyota_service_models.dart';

const toyotaServiceVehiclePath = '/toyota-service/new/vehicle';
const toyotaServiceNonToyotaPath = '/toyota-service/new/non-toyota';
const toyotaServiceAddVehiclePath = '/toyota-service/new/add-vehicle';
const toyotaServiceFulfillmentPath = '/toyota-service/new/fulfillment';
const toyotaServiceTypePath = '/toyota-service/new/service';
const toyotaServiceDetailsPath = '/toyota-service/new/details';
const toyotaServiceSchedulePath = '/toyota-service/new/schedule';
const toyotaServiceAddressPath = '/toyota-service/new/address';
const toyotaServiceReviewPath = '/toyota-service/new/review';

String toyotaServiceSubmittedPath(String id) => '/toyota-service/submitted/$id';
String toyotaServiceBookingPath(String id) => '/toyota-service/bookings/$id';

String toyotaServiceResumePath(
  ToyotaServiceDraft draft, {
  ToyotaServiceOptions? options,
}) {
  if (!draft.hasVehicle) return toyotaServiceVehiclePath;
  if (!draft.hasFulfillment) return toyotaServiceFulfillmentPath;
  if (options != null && !options.supportsFulfillmentSelection(draft)) {
    return toyotaServiceFulfillmentPath;
  }
  if (!draft.hasService) return toyotaServiceTypePath;
  if (options != null && !options.supportsServiceSelection(draft)) {
    return toyotaServiceTypePath;
  }
  if (!draft.hasDetails) return toyotaServiceDetailsPath;
  if (!draft.hasSchedule) return toyotaServiceSchedulePath;
  if (!draft.hasThsAddress) return toyotaServiceAddressPath;
  if (options != null && !options.coversThsAddress(draft)) {
    return toyotaServiceAddressPath;
  }
  return toyotaServiceReviewPath;
}

const adminPanelPath = '/admin';
const adminToyotaServiceQueuePath = '/admin/toyota-service/bookings';
String adminToyotaServiceBookingPath(String id) =>
    '/admin/toyota-service/bookings/$id';
