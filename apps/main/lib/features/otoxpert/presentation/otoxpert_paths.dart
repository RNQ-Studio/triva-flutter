/// Menu OtoXpert: booking, cek No. Rangka, dan simulasi biaya servis
/// (revisi 4 September 2026 memindahkan dua alat bantu itu ke sini).
const otoxpertPath = '/otoxpert';

/// Alur booking OtoXpert (stepper).
const otoxpertBookingIntakePath = '/otoxpert/booking';
String otoxpertBookingPath(String id) => '/otoxpert/bookings/$id';

const adminOtoxpertQueuePath = '/admin/otoxpert/bookings';
String adminOtoxpertBookingPath(String id) => '/admin/otoxpert/bookings/$id';
