# web-terminal with OpenCode

Tooling Image for use in the OpenShift web terminal.

Install web-terminal in your cluster. Login using oc as cluster-admin.

```bash
curl -Ls https://raw.githubusercontent.com/eformat/web-terminal/refs/heads/web-terminal-all-in-one.sh | bash -s
```

## Building and running locally
```bash
podman build -f Containerfile -t opencode:latest

podman run --rm -it -v ~/.config/opencode:/home/user/.config/opencode:z -v ~/.local/share/opencode/:/home/user/.local/share/opencode/:rw,U -v ~/.local/state/opencode/:/home/user/.local/state/opencode/:rw,U localhost/opencode:latest /bin/bash

```

## Create the configmap to configure opencode

```bash
oc create cm opencode-config --from-file=/home/noelo/.config/opencode/opencode.json -n openshift-terminal

oc label cm opencode-config controller.devfile.io/mount-to-devworkspace=true 

oc label cm opencode-config controller.devfile.io/watch-configmap=true 

oc annotate cm opencode-config controller.devfile.io/mount-path=/home/user/.config/opencode 
```

