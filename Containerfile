FROM quay.io/devfile/base-developer-image:ubi10-latest
# registry.redhat.io/web-terminal/web-terminal-tooling-rhel9@sha256:0b133afa920b5180a3c3abe3dd5c73a9cfc252a71346978f94adcb659d683404

USER root

ARG RHEL_RHSM_USERNAME
ARG RHEL_RHSM_PASSWORD

ENV ARGOCD_VERSION=3.2.0 \
    YQ_VERSION=4.49.1 \
    HELM_VERSION=4.0.1 \
    OC_VERSION=4.20.3 \
    JQ_VERSION=1.8.1 \
    VAULT_VERSION=1.21.1 \
    KUSTOMIZE_VERSION=5.8.0

ENV PACKAGES="zip iputils bind-utils net-tools nodejs npm nodejs-nodemon python3 python3-pip httpd-tools gh"

RUN dnf -y install \
    ${PACKAGES} && \
    dnf -y -q clean all && rm -rf /var/cache/yum && \
    ln -s /usr/bin/node /usr/bin/nodejs && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    echo "🐍🐍🐍🐍🐍"

# # python global deps
# RUN pip install --no-cache-dir ansible && \
#     echo "🦀🦀🦀🦀🦀"

# argo
# RUN curl -sL https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64 -o /usr/local/bin/argocd && \
#     chmod -R 775 /usr/local/bin/argocd && \
#     echo "🐙🐙🐙🐙🐙"

# oc client
RUN rm -f /usr/bin/oc && \
    curl -sL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz | tar -C /usr/local/bin -xzf - && \
    echo "🐨🐨🐨🐨🐨"

# jq / yq
RUN curl -sLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 && \
    chmod +x /usr/local/bin/jq && \
    curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq && \
    echo "🦨🦨🦨🦨🦨"

# helm
# RUN curl -skL -o /tmp/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
#     tar -C /tmp -xzf /tmp/helm.tar.gz && \
#     mv -v /tmp/linux-amd64/helm /usr/local/bin && \
#     chmod -R 775 /usr/local/bin/helm && \
#     rm -rf /tmp/linux-amd64 && \
#     rm -rf /tmp/helm.tar.gz && \
#     echo "⚓️⚓️⚓️⚓️⚓️"

# # vault
# RUN curl -skL -o /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
#     unzip -q /tmp/vault.zip -d /tmp vault && \
#     mv -v /tmp/vault /usr/local/bin && \
#     chmod -R 775 /usr/local/bin/vault && \
#     rm -rf /tmp/vault.zip && \
#     echo "🔑🔑🔑🔑🔑"

# Install kustomize
# RUN curl -skL -o /tmp/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
#     tar -C /tmp -xzf /tmp/kustomize.tar.gz && \
#     mv -v /tmp/kustomize /usr/local/bin && \
#     chmod -R 775 /usr/local/bin/kustomize && \
#     rm -rf /tmp/linux-amd64 && \
#     rm -rf /tmp/kustomize.tar.gz && \
#     echo "🐾🐾🐾🐾🐾"

# google chrome for headless mode
# COPY google-chrome.repo /etc/yum.repos.d/google-chrome.repo

# RUN subscription-manager register --username "${RHEL_RHSM_USERNAME}" --password "${RHEL_RHSM_PASSWORD}" && \
#     subscription-manager repos --enable codeready-builder-for-rhel-10-$(arch)-rpms && \
#     dnf install -y google-chrome-stable && \
#     subscription-manager unregister && \
#     dnf -y clean all && \
#     rm -rf /var/cache/dnf && \
#     echo "🐕🐕🐕🐕🐕"

USER user

RUN mkdir /home/user/workspace
WORKDIR /home/user


# RUN curl -LsSf https://astral.sh/uv/install.sh | sh
# RUN curl -fsSL https://claude.ai/install.sh | bash
RUN ls -altr
RUN npm i opencode-ai@latest
RUN /home/user/node_modules/opencode-linux-x64/bin/opencode stats

RUN ls -altr .
RUN ls -latr .config/opencode

RUN mv /home/user/.config/ /home/user/.config-orig
RUN mv /home/user/node_modules /home/user/.node_modules.orig
RUN mv /home/user/package-lock.json /home/user/.package-lock.json.orig
RUN mv /home/user/package.json /home/user/.package.json.orig
RUN mv /home/user/.npm /home/user/.npm.orig

# we have to customize all this as there are not great overrides unfortunately
RUN rm -f .bashrc .viminfo .bash_profile .bash_logout .gitconfig
USER root

# RUN curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
ADD entrypoint.sh /entrypoint.sh
ADD .copy-files ../tooling/.copy-files
ADD .stow-local-ignore ../tooling/.stow-local-ignore
ADD .bashrc ../tooling/.bashrc
ADD .installed_tools.txt ../tooling/.installed_tools.txt

RUN chmod 755 /entrypoint.sh && chown root:root /entrypoint.sh
RUN chmod 664 ../tooling/.copy-files && chown user:root ../tooling/.copy-files
RUN chmod 664 ../tooling/.stow-local-ignore && chown user:root ../tooling/.stow-local-ignore
RUN chmod 660 ../tooling/.bashrc && chown user:root ../tooling/.bashrc
RUN chmod 440 ../tooling/.installed_tools.txt && chown user:root ../tooling/.installed_tools.txt

ENV OPENCODE_CONFIG=/home/user/opencode/config-map/opencode.json
ENV OPENCODE_CONFIG_DIR=/home/user/.config/opencode/

USER user
WORKDIR /home/user 