import '../domain/appraisal_models.dart';

const appraisalIdentityPath = '/appraisals/new/identity';
const appraisalDetailsPath = '/appraisals/new/details';
const appraisalConditionPath = '/appraisals/new/condition';
const appraisalPhotosPath = '/appraisals/new/photos';
const appraisalReviewPath = '/appraisals/new/review';
const appraisalActivityPath = '/activity';

String appraisalDetailPath(String id) => '/appraisals/$id';
String appraisalSubmittedPath(String id) => '/appraisals/submitted/$id';
String appraisalResultPath(String id) => '/appraisals/$id/result';
String appraisalCompletePath(String id, String outcome) =>
    '/appraisals/$id/complete?outcome=$outcome';

String appraisalResumePath(AppraisalDraft draft) {
  if (!draft.hasIdentity) return appraisalIdentityPath;
  if (!draft.hasDetails) return appraisalDetailsPath;
  if (!draft.hasCondition) return appraisalConditionPath;
  if (!draft.hasAllPhotos) return appraisalPhotosPath;
  return appraisalReviewPath;
}
