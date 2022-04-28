# Kubernetes Training Materials

Demos für various topics of the LFD458 (Kubernetes for Administrators) and LFS459 (Kubernetes for Application Developers)
courses by the Linux Foundation.

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
