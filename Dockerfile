FROM ubuntu:18.04

MAINTAINER Alexander Fillbrunn <alexander.fillbrunn@uni.kn>

ENV DOWNLOAD_URL https://download.knime.org/analytics-platform/linux/knime-latest36-linux.gtk.x86_64.tar.gz
ENV INSTALLATION_DIR /usr/local
ENV KNIME_DIR $INSTALLATION_DIR/knime
ENV HOME_DIR /home/knime

# Install everything
# HACK: Install tzdata at the beginning to not trigger an interactive dialog later on
RUN apt-get update \
    && apt-get install -y software-properties-common curl \
    && apt-get install -y tzdata \
    && apt-add-repository -y ppa:webupd8team/java \
    && apt-get update \
    && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
    && apt-get install -y oracle-java8-set-default libgtk2.0-0 libxtst6 \
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

# docker run -e DISPLAY=192.168.99.1:0 -d --name knime -v /Users/Alexander/knime-workspace:/home/knime/workspace -t knime
