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
[configmaps/configmap-pod.yaml]
Then exec into the container using `kubectl exec -it  configmap-demo -- sh` and show the
mounted config files in `/config` and the `MY_ENV_VAR` environment variable.

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

After finishing the demo, reset the state using `./troubleshooting/teardown.sh`.
