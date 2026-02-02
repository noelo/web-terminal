# web-terminal with OpenCode

Tooling Image for use in the OpenShift web terminal.

Install web-terminal in your cluster. Login using oc as cluster-admin.

```bash
curl -Ls https://raw.githubusercontent.com/noelo/web-terminal/refs/heads/web-terminal-all-in-one.sh | bash -s
```

## Building and running locally
```bash
podman build -f Containerfile -t opencode:latest

podman run --rm -it -v ~/.config/opencode:/home/user/.config/opencode:z -v ~/.local/share/opencode/:/home/user/.local/share/opencode/:rw,U -v ~/.local/state/opencode/:/home/user/.local/state/opencode/:rw,U localhost/opencode:latest /bin/bash
```
[NOTE] You'll need to set the correct environment variables for keys and urls.
These values are stored in the file env-vars.sh

```
CONTEXT7_API_KEY=12345
RH_MAAS_Llama_3_2_3B_Instruct_API_KEY=12345
OPENCODE_LLS_URL=http://example.com/v1/openai/v1
RH_MAAS_URL=https://example.com:443/v1
CLAUDE_SKILLS_MCP_URL=http://example.com/mcp
```




## Create the configmap and secrets to configure opencode

```bash
oc create cm opencode-config --from-file=/home/noelo/.config/opencode/opencode.json -n openshift-terminal
oc create secret generic opencode-env-secret --from-env-file=/home/noelo/.config/opencode/env-vars.sh -n openshift-terminal

oc label cm opencode-config controller.devfile.io/mount-to-devworkspace=true controller.devfile.io/watch-configmap=true
oc label secret opencode-env-secret controller.devfile.io/mount-to-devworkspace=true controller.devfile.io/watch-secret=true

oc annotate cm opencode-config controller.devfile.io/mount-path=/home/user/.config/opencode 
oc annotate secret opencode-env-secret controller.devfile.io/mount-as=env
```


## command line script
```
opencode run "/openshift-mcp:cluster-health-check:mcp"
```
