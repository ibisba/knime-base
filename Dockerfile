FROM ubuntu:18.04

ENV DOWNLOAD_URL https://download.knime.org/analytics-platform/linux/knime_4.0.1.linux.gtk.x86_64.tar.gz
ENV INSTALLATION_DIR /usr/local
ENV KNIME_DIR $INSTALLATION_DIR/knime
ENV HOME_DIR /home/knime

# Install everything
# HACK: Install tzdata at the beginning to not trigger an interactive dialog later on
RUN apt-get update \
    && apt-get install -y software-properties-common curl \
    && apt-get install -y tzdata \
    && apt-get install -y libgtk2.0-0 libxtst6 \
    && apt-get install -y libwebkitgtk-3.0-0 \
    && apt-get install -y python python-dev python-pip \
    && apt-get install -y curl \
    && apt-get install -y r-base r-recommended

 # Download KNIME
RUN curl -L "$DOWNLOAD_URL" | tar vxz -C $INSTALLATION_DIR \
    && mv $INSTALLATION_DIR/knime_* $INSTALLATION_DIR/knime

# Clean up
RUN apt-get --purge autoremove -y software-properties-common curl \
    && apt-get clean

# Install pandas and protobuf so KNIME can communicate with Python
RUN pip install pandas && pip install protobuf

# Install Rserver so KNIME can communicate with R
RUN R -e 'install.packages(c("Rserve"), repos="http://cran.rstudio.com/")'

ENTRYPOINT $KNIME_DIR/knime
