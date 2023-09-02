FROM ubuntu

ENV SRC_DIR /app/lobster/dev

ENV BUILD_DIR $SRC_DIR/build

ENV DISPLAY :0

ENV USERNAME developer

WORKDIR /app

RUN apt update

# Ubuntu specific issues
# - DEBIAN_FRONTEND=noninteractive prevents from asking timezone
# - --no-install-recommends prevents install extras
# - specific deps for https
#   - apt-transport-https
#   - software-properties-common

# Undocumented dep
# - libxext-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-transport-https sudo \
    software-properties-common \
    git cmake wget g++ mesa-common-dev libxext-dev

RUN wget -qO /app/ninja.gz https://github.com/ninja-build/ninja/releases/latest/download/ninja-linux.zip \
    && gunzip /app/ninja.gz \
    && chmod a+x /app/ninja
    
# link the executable so we can call it anywhere
RUN ln -s /app/ninja /bin/ninja

# the docs ended with .git
# my preference is no extension
RUN git clone https://github.com/aardappel/lobster

# the docs didn't do this like this
# my preference and seems to be best practice use a build dir
RUN cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja
RUN ninja -C $BUILD_DIR

# link the executable so we can call it anywhere
RUN ln -s /app/lobster/bin/lobster /bin/lobster

# create and switch to a user
RUN echo "backus ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN useradd --no-log-init --home-dir /home/$USERNAME --create-home --shell /bin/bash $USERNAME
RUN adduser $USERNAME sudo
USER $USERNAME

WORKDIR /home/$USERNAME

COPY bin .

ENTRYPOINT ["lobster"]

CMD ["main.lobster"]

# Needs X11 on linux
# CMD ["/app/lobster/samples/pythtree.lobster"]