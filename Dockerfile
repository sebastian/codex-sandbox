FROM node:current-bookworm

ARG DOTNET_CHANNEL=LTS
ARG ASDF_VERSION=v0.15.0

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    DOTNET_ROOT=/usr/share/dotnet \
    ASDF_DIR=/opt/asdf-vm \
    ASDF_DATA_DIR=/root/.asdf

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        dirmngr \
        fd-find \
        gawk \
        git \
        gpg \
        gpg-agent \
        gnupg \
        jq \
        less \
        openssh-client \
        python3 \
        python3-pip \
        python3-venv \
        ripgrep \
        sudo \
        unzip \
        vim \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "$DOTNET_ROOT" \
    && curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel "$DOTNET_CHANNEL" --quality ga --install-dir "$DOTNET_ROOT" \
    && ln -sf "$DOTNET_ROOT/dotnet" /usr/local/bin/dotnet \
    && rm -f /tmp/dotnet-install.sh

RUN git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch "$ASDF_VERSION" --depth 1 \
    && printf '\n. %s/asdf.sh\n' "$ASDF_DIR" >> /root/.bashrc

ENV PATH="${ASDF_DIR}/bin:${ASDF_DIR}/shims:${PATH}"

RUN npm install -g @openai/codex@latest

WORKDIR /workspace

CMD ["bash"]
