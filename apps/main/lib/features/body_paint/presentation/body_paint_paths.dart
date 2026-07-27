const bodyPaintPath = '/body-paint';
String bodyPaintEstimatePath(String id) => '/body-paint/estimates/$id';
String bodyPaintBookingPath(String id) => '/body-paint/estimates/$id/booking';

const adminBodyPaintQueuePath = '/admin/body-paint/estimates';
String adminBodyPaintEstimatePath(String id) =>
    '/admin/body-paint/estimates/$id';
String adminBodyPaintPublishPath(String id) =>
    '/admin/body-paint/estimates/$id/publish';
