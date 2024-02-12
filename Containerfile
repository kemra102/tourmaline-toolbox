FROM quay.io/fedora/fedora:latest as build

ARG ATUIN_VERSION='18.0.1'
ARG ATUIN_FILE_NAME="atuin-v${ATUIN_VERSION}-x86_64-unknown-linux-gnu"

RUN mkdir -p /tmp/bin

RUN curl -sL "https://github.com/atuinsh/atuin/releases/download/v${ATUIN_VERSION}/${ATUIN_FILE_NAME}.tar.gz" --output - | tar -xzf - -C /tmp && \
    cp "/tmp/${ATUIN_FILE_NAME}/atuin" /tmp/bin/ && \
    cp "/tmp/${ATUIN_FILE_NAME}/completions/_atuin" /tmp/

RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir /tmp/bin

RUN curl -fLo /tmp/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x /tmp/bin/yadm

# From https://github.com/ublue-os/fedora-distrobox
FROM ghcr.io/ublue-os/fedora-distrobox:latest

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience powered by Fedora"

COPY --from=build /tmp/bin/* /usr/bin/
COPY --from=build /tmp/_atuin /usr/share/zsh/site-functions/

COPY extra-packages /

RUN dnf -y upgrade && \
    dnf -y install $(</extra-packages) && \
    dnf clean all

RUN rm /extra-packages

RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree
