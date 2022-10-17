# -*- mode: dockerfile -*-
# Copyright (c) 2012-2022 Peter Morgan <peter.james.morgan@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
ARG BUILD_IMAGE
FROM ${BUILD_IMAGE} as build
ARG GITHUB_REPOSITORY
ARG BUILD_COMMAND

RUN mkdir -p /${GITHUB_REPOSITORY}
WORKDIR /${GITHUB_REPOSITORY}
ADD / /${GITHUB_REPOSITORY}/
RUN ${BUILD_COMMAND}
RUN beam-docker-release-action/mkimage


FROM scratch
ARG GITHUB_REPOSITORY

LABEL org.opencontainers.image.authors="peter.james.morgan@gmail.com"
LABEL org.opencontainers.image.description="BEAM docker release from scratch"
LABEL org.opencontainers.image.licenses="http://www.apache.org/licenses/LICENSE-2.0"
LABEL org.opencontainers.image.url="https://github.com/shortishly/beam-docker-release-action"

ENV BINDIR /erts/bin
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV TZ GMT

ENV RELEASE_SYS_CONFIG /release/sys.config
ENV RELEASE_VM_ARGS /release/vm.args

ENTRYPOINT ["/erts/bin/erlexec", "-boot_var", "ERTS_LIB_DIR", "/lib", "-boot_var", "RELEASE_LIB", "/lib", "-boot", "/release/start", "-noinput", "-no_epmd", "-proto_dist", "inet_tls", "-config", "/release/sys.config", "-args_file", "/release/vm.args"]

COPY --from=build /${GITHUB_REPOSITORY}/_image/ /
