local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.openshift4_version;
local common = import 'common.libsonnet';

local name = 'clusterversion-make-unmanaged';
local namespace = 'openshift-cluster-version';

local addSyncWave = function(object) object {
  metadata+: {
    annotations+: {
      'argocd.argoproj.io/sync-wave': '-10',
    },
  },
};

local script = importstr './make_unmanaged/patch-clusterversion.sh';

local role = kube.ClusterRole(name) {
  rules: [
    {
      apiGroups: [ 'config.openshift.io' ],
      resources: [ 'clusterversions' ],
      resourceNames: [ 'version' ],
      verbs: [ 'get', 'patch', 'update' ],
    },
  ],
};

local serviceAccount = kube.ServiceAccount(name) {
  metadata+: { namespace: namespace },
};

local roleBinding = kube.ClusterRoleBinding(name) {
  subjects_: [ serviceAccount ],
  roleRef_: role,
};

local job = kube.Job(name) {
  metadata+: {
    namespace: namespace,
    annotations+: {
      'argocd.argoproj.io/hook': 'Sync',
      'argocd.argoproj.io/hook-delete-policy': 'HookSucceeded',
    },
  },
  spec+: {
    template+: {
      spec+: {
        serviceAccountName: serviceAccount.metadata.name,
        containers_+: {
          ensure: kube.Container(name) {
            image: '%s/%s:%s' % [ params.images.kubectl.registry, params.images.kubectl.image, params.images.kubectl.tag ],
            workingDir: '/export',
            command: [ 'sh' ],
            args: [ '-eu', '-c', script ],
            env: [
              { name: 'HOME', value: '/export' },
            ],
            volumeMounts: [
              { name: 'export', mountPath: '/export' },
            ],
          },
        },
        volumes+: [
          { name: 'export', emptyDir: {} },
        ],
      },
    },
  },
};

{
  [if common.UpgradeControllerEnabled then '00_make_unmanaged']: [
    addSyncWave(role),
    addSyncWave(serviceAccount),
    addSyncWave(roleBinding),
    addSyncWave(job),
  ],
}
