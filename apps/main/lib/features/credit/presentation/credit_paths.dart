const creditPath = '/credit';

String creditFromAppraisalPath(String appraisalId) =>
    '$creditPath?appraisal_id=$appraisalId';

String creditFromSalesPath(
  String programId, {
  String campaignSource = 'sales_share',
}) =>
    Uri(
      path: creditPath,
      queryParameters: {
        'program_id': programId,
        'campaign_source': campaignSource,
      },
    ).toString();

/// Membuka simulasi kredit untuk unit hasil pop-up upgrade, lengkap dengan
/// hasil appraisal yang dipakai sebagai uang muka.
String creditUpgradePath({
  required String programId,
  required String appraisalId,
}) =>
    Uri(
      path: creditPath,
      queryParameters: {
        'program_id': programId,
        'appraisal_id': appraisalId,
        'campaign_source': 'appraisal_upgrade',
      },
    ).toString();

String creditSimulationPath(String id) => '/credit/simulations/$id';
