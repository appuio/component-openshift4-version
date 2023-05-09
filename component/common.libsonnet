local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.openshift4_version;

local upgradeControllerEnabled = std.member(inv.applications, 'openshift-upgrade-controller');

{
  UpgradeControllerEnabled: upgradeControllerEnabled,
}
