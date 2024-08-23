ARG PG_BASE_IMAGE=postgres:15.6

ARG APT_PKGS_DEV=""
ARG APT_PKGS_RUN="            \
unzip                         \
"

FROM $PG_BASE_IMAGE AS db
ARG APT_PKGS_DEV
ARG APT_PKGS_RUN

ENV DEBIAN_FRONTEND noninteractive
RUN \
	# Install build and runtime requirements {{{ \
	set -eux \
	\
	# via apt-get \
	&& apt-get update && apt-get install -y --no-install-recommends \
		$APT_PKGS_DEV $APT_PKGS_RUN \
	# }}} \
	&& true \
#RUN \
	# Clean up build requirements {{{ \
	set -eux \
	\
	# Remove packages \
	&& apt-get -qq purge --auto-remove ${APT_PKGS_DEV} \
	# No `apt-get clean`: \
	# See `cat /etc/apt/apt.conf.d/docker-clean`. \
	&& rm -rf /var/lib/apt/lists/* \
	# }}} \
	&& true
