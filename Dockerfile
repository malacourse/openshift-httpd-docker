FROM rhel7
MAINTAINER Mike LaCourse email: mlacours@redhat.com


ENV HTTPD_VERSION=2.4

RUN yum repolist > /dev/null && \
    yum install -y yum-utils && \
    yum-config-manager --disable \* &> /dev/null && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    INSTALL_PKGS="gettext hostname nss_wrapper bind-utils httpd24 httpd24-mod_ssl" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

ENV HTTPD_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/httpd/ \
    HTTPD_APP_ROOT=/opt/app-root \
    HTTPD_CONFIGURATION_PATH=/opt/app-root/etc/httpd.d \
    HTTPD_MAIN_CONF_PATH=/etc/httpd/conf \
    HTTPD_MAIN_CONF_D_PATH=/etc/httpd/conf.d \
    HTTPD_VAR_RUN=/var/run/httpd \
    HTTPD_DATA_PATH=/var/www \
    HTTPD_DATA_ORIG_PATH=/opt/rh/httpd24/root/var/www \
    HTTPD_LOG_PATH=/var/log/httpd24 \
    HTTPD_SCL=httpd24

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=${HTTPD_APP_ROOT}/scl_enable \
    ENV=${HTTPD_APP_ROOT}/scl_enable \
    PROMPT_COMMAND=". ${HTTPD_APP_ROOT}/scl_enable"

COPY ./root /

ADD common.sh /common.sh
RUN ./httpd-prepare

# Add the tar file of the web site
ADD src/html /var/www/html

USER 1001

VOLUME ["${HTTPD_DATA_PATH}"]
VOLUME ["${HTTPD_LOG_PATH}"]

ADD run-httpd.sh /run-httpd.sh

CMD ["/run-httpd.sh"]
