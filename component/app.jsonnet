local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.openshift4_version;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('openshift4-version', params.namespace);

{
  'openshift4-version': app,
}
