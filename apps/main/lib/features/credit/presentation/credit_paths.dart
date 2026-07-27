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

String creditSimulationPath(String id) => '/credit/simulations/$id';
