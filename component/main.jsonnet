// main template for openshift4-version
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.openshift4_version;

local clusterVersion = kube._Object('config.openshift.io/v1', 'ClusterVersion', 'version') {
  spec: params.spec,
};

// Define outputs below
{
  version: clusterVersion,
}
