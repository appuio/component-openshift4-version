local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.openshift4_version;
local argocd = import 'lib/argocd.libjsonnet';

local upgradeControllerEnabled = std.member(inv.applications, 'openshift-upgrade-controller');

local ignoreDesiredVersion = {
  spec+: {
    ignoreDifferences+: [
      {
        group: 'config.openshift.io',
        kind: 'ClusterVersion',
        name: 'version',
        jsonPointers: [
          '/spec/desiredUpdate/force',
          '/spec/desiredUpdate/image',
          '/spec/desiredUpdate/version',
        ],
      },
    ],
  },
};

local app = argocd.App('openshift4-version', 'syn', secrets=false) + if upgradeControllerEnabled then ignoreDesiredVersion else {};

{
  'openshift4-version': app,
}
