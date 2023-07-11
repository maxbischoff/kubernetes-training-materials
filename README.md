# Kubernetes Training Materials

Demos für various topics of the LFD458 (Kubernetes for Administrators) and LFS459 (Kubernetes for Application Developers)
courses by the Linux Foundation.

## Volumes Demo

This Demo showcases the usage of an `emptyDir` volume in one ore more containers.
The files in [volumes/](volumes/) are intended to be edited incrementally
to showcase the required configurations:

1. Start with [the volume-less pod](volumes/0-volumeless-pod.yaml) as your base
1. Add an emptyDir volume to this base and mount it: [volumes/1-emptydir.yaml](volumes/1-emptydir.yaml)
1. Apply the emptyDir pod to the cluster
1. Exec into the pod using `kubectl exec -it emptydir-demo -- sh` and showcase the volume under `/scratch`
1. Add a second container that mounts the emptyDir volume: [volumes/2-shared.yaml](volumes/2-shared.yaml)
1. Apply the shared-volume pod to the cluster
1. Exec into the first container using `kubectl exec -it shared-volumes-demo -c busybox -- sh` create a file under `/scratch`
1. Exec into the second container using `kubectl exec -it shared-volumes-demo -c otherbox -- sh` and show that file is available under `/other`

## ConfigMap Demo

This Demo showcases how to use `kubectl create` to create a ConfigMap
and making ConfigMap data available as envirnoment variables and volumes.

To run the demo, showcase the creation of a config file and the `kubectl create` command
as done in [configmaps/setup.sh](configmaps/setup.sh).
Then incrementally edit the [base-pod from the volumes demo](volumes/0-volumeless-pod.yaml)
adding a volume, volumeMount and `env` section as demonstrated in
[configmaps/configmap-pod.yaml](configmaps/configmap-pod.yaml)
Then exec into the container using `kubectl exec -it  configmap-demo -- sh` and show the
mounted config files in `/config` and the `MY_ENV_VAR` environment variable.

## Rolling Upgrade Demo

This Demo shows the rolling upgrade behavior of a deployment.

Before the demo apply the demo-deployment using `kubectl apply -f rolling-upgrade/deployment.yaml`.

To showcase the upgrade behavior, update the deployment, e.g. by running
`kubectl set image deployment deployment-demo busybox=busybox:latest`.
Then showcase the state change of the objects in the cluster using
`watch -n 0.1 kubectl get po,rs -l app=deployment-demo`.
Alternatively, you can show the events using e.g. `kubectl get events -w`.

There are also two alternative deployment manifests in the [rolling-upgrade folder](rolling-upgrade/)
for showcasing the behavior when only setting `maxSurge` or `maxUnavailable`.

## Headless Service Demo

This demo showcases how a headless Service differs from a normal clusterIp Service.

Apply the manifests in [headless-service/](headless-service/) using
`kubectl apply -f headless-service`.

Showcase DNS Resolution of the headless service using:
`kubectl exec -it client -- dig +search nginx-headless`
Compare this with the output of `kubectl get endpoints nginx-headless`
and the resolution of the clusterIp Service `kubernetes` using
`kubectl exec -it client -- dig +search kubernetes`.

## Troubleshooting Demo

This Demo showcases various broken pods/deployments with different
errors and how to investigate these errors.

Create a namespace and set your current kube-context to it using `./troubleshooting/setup.sh`.

You can now apply the YAML files to create the various broken pods/deployments using `kubectl apply -f troubleshooting/`.
The following table explains what is wrong with them and how to showcase the issue:

| Resource                      | Issue | Command for Observing the Error |
| ----------------------------- | --- | --- |
| deployment/memory-constraints | No pods appear for the deployment, because the Pod's memory limit of 800Mi is over the LimitRange's maximum of 500Mi | `kubectl describe rs -l app=memory-constraints` -> events |
| pod/busybox | The executed script in the pod's container "crashes" repeatedly. The logs show an "useful error message" | `kubetl get pod busybox` -> State, `kubectl logs busybox`-> error message |
| pod/hungry | The pod is stuck in `Pending` state, since its requests of 10 cpu and 5Ti memory don't fit on the lab nodes. | `kubetl describe pod hungry` -> events, resource.requests |
| pod/nginx | The pod's image `nginx:1.18.7` doesn't exist, causing it to go into `ImagePullBackoff` | `kubectl describe pod nginx` -> events, image |
| pod/sleeper | The pod's nodeSelector `test=missing` doesn't fit any of the lab nodes, causing it to be stuck in Pending | `kubectl get pod sleeper -o yaml` -> nodeSelector, conditions |
| pod/root | The container has `runAsNonRoot` set to `true` but the image runs as root. | `kubectl describe pod root` -> events, securityContext |
| pod/writer | The container has `readOnlyRootFilesystem` set to `true`, but the script attempts to create a file. | `kubectl logs writer` -> error message |

After finishing the demo, reset the state using `./troubleshooting/teardown.sh`.

## Pod Affinity Demo

This demo showcases the behavior of pods with pod anti-affinities.

First, ensure your nodes are labelled with the
[standard kubernetes topology labels](https://kubernetes.io/docs/reference/labels-annotations-taints/#topologykubernetesioregion)
such that all nodes have the same region but different zones, e.g. by running:

```sh
kubectl label nodes topology.kubernetes.io/region=europe --all
for node in $(kubectl get nodes -o name); do kubectl label $node topology.kubernetes.io/zone=zone-$RANDOM; done
```

Then deploy the deployments in the [pod-anti-affinities folder](pod-anti-affinities/) using `kubectl apply -f pod-anti-affinities/`.
Finally showcase the created pods using `kubectl get pods` and for pending pods also show the events.

This will show:

* Two pods of the deployment `preferred-anti-affinity-demo` that are successfully scheduled (since the anti-affinity only
  preferred the pods being placed into different regions & zones
* Two pods of the deployment `required-anti-affinity-demo` of which one is stuck in pending,
  since the required antiAffinity would require a node in a different region to exist

## Pod Spread Demo

This demo showcases scheduling behavior when using pod topology spread constraints. It assumes a two-node cluster.
It is split into two parts, both using a `maxSkew` of `1` with different settings for `whenUnsatisfiable`.
The demo for `DoNotSchedule` should be done first:

1. Deploy the [donotschedule manifest](pod-spread/topology-spread-constraints-donotschedule.yaml) using
   `kubectl apply -f pod-spread/topology-spread-constraints-donotschedule.yaml`
1. Show that only one pod of the demo Deployment has been scheduled with the rest being stuck in `Pending` state using
   `kubectl get pods -l app=topology-spread-constraints-donotschedule-demo -o wide`. 
   The `-helper` pod has the purpose of blocking the whole node for the Deployment using an `podAntiAffinity`.
1. Delete the helper pod using `kubectl delete pod topology-spread-constraints-donotschedule-demo-helper`.
   This "frees" the node again for scheduling Pods of the demo Deployment
1. Show that all Pods are now scheduled, and that they are evenly distributed amongst both nodes using
   `kubectl get po -o wide`

Afterwards you can contrast this with the behavior of the `ScheduleAnyway` setting:

1. Show the difference between the first and second demo e.g. by using `colordiff -y pod-spread/*`.
   The only difference between the demos are the names, the `app` labels (and selectors) and the `whenUnsatisfiable`
   setting
1. Deploy the demo using `kubectl apply -f pod-spread/topology-spread-constraints-scheduleanyway.yaml`
1. Show that all pods are scheduled successfully, but on the same node (since the other one is blocked by the helper)
   `kubectl get pods -l app=topology-spread-constraints-scheduleanyway-demo -o wide`
1. Delete all demo pods and show that in the "good" case (where no node is blocked) pods are distributed equally between
   nodes using `kubectl delete po topology-spread-constraints-scheduleanyway-demo-helper; kubectl delete pods -l app=topology-spread-constraints-scheduleanyway-demo`
   and then `kubectl get pods -l app=topology-spread-constraints-scheduleanyway-demo -o wide`

Clean up the demo by running `kubectl delete -f pod-spread`.

## Showing where the certificate authentication module extracts user-info from

(Only works when authenticating with a client-certificate)

Extract the certificate from your kubeconfig (assumes only one user to exist):

```sh
kubectl config view -o jsonpath='{.users[0].user.client-certificate-data}' --raw | base64 -d > cert.pem
```

Then use `openssl x509 -in cert.pem -noout -text | less` to show the certificate data.
Showcase the Subject where the username and -group are extracted from the Organization (O) and Common Name (CN) field respectively.
