/// Simulasi kredit cepat ACC (revisi 4 September 2026): pilih unit, OTR,
/// DP 20/25/30%, tenor 1-5 tahun.
const creditPath = '/credit';

/// Simulasi lengkap (trade-in, perbandingan skenario, simpan) yang lama.
const creditAdvancedPath = '/credit/lengkap';

String creditQuickProgramPath(String programId) =>
    Uri(path: creditPath, queryParameters: {'program_id': programId})
        .toString();

String creditFromAppraisalPath(String appraisalId) =>
    '$creditAdvancedPath?appraisal_id=$appraisalId';

String creditFromSalesPath(
  String programId, {
  String campaignSource = 'sales_share',
}) =>
    Uri(
      path: creditAdvancedPath,
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
      path: creditAdvancedPath,
      queryParameters: {
        'program_id': programId,
        'appraisal_id': appraisalId,
        'campaign_source': 'appraisal_upgrade',
      },
    ).toString();

String creditSimulationPath(String id) => '/credit/simulations/$id';
