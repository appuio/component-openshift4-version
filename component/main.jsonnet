// main template for openshift4-version
local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.openshift4_version;

local cluster_gt_411 =
  params.openshiftVersion.Major == '4' &&
  std.parseInt(params.openshiftVersion.Minor) >= 11;

local clusterVersion = kube._Object('config.openshift.io/v1', 'ClusterVersion', 'version') {
  metadata+: {
    annotations+: {
      'argocd.argoproj.io/sync-options': 'Prune=false',
    },
  },
  spec: {
    [if cluster_gt_411 then 'capabilities']: {
      baselineCapabilitySet: 'v4.11',
    },
    channel: 'stable-%(Major)s.%(Minor)s' % params.openshiftVersion,
  } + com.makeMergeable(params.spec),
};

// Define outputs below
{
  version: clusterVersion,
}
