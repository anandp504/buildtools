package builddata;

$buildlog = "/tmp/build.log";
$releaseDir = "/opt/scm_repo";
$libDepotPath = "//depot/Tumri/tas/int/lib";
$templateDir = "/opt/Tumri/buildui/data";
$releaseUrl = "http://build01.dev.tumri.net/";

@qa_mailing_list = qw(ensemble-dco-engineering);
@dev_qa_mailing_list = qw(ensemble-dco-engineering );
@release_mailing_list = qw(iot ensemble-dco-engineering ensemble-techops);
@lib_release_mailing_list = qw(ensemble-dco-engineering ensemble-techops);
@business_mailing_list=qw(iot ensemble-dco-engineering ensemble-techops);

%components = ();
1;
