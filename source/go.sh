# GOROOT is for compiler/tools that comes from go installation.
# GOPATH is for your own go projects / 3rd party libraries (downloaded with "go get").

# compiler
# Where is the compiler?
# https://golang.org/doc/install?download=go1.10.3.linux-amd64.tar.gz
# tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz
#export GOROOT=$HOME/go

# there is only one root folder. This never has a :
export GOROOT=/usr/local/go

# The GOPATH environment variable is used to specify directories outside of $GOROOT that contain the source for Go projects and their binaries.
# It can be a list.
# It must not be set to GOROOT
# It must not be empty
# It's like GOROOT but for stuff downloaded with go get
export GOPATH=$HOME/go

export PATH=$PATH:$GOROOT/bin
# Add all gopath bin directories
#export PATH=$PATH:${GOROOT//://bin:}/bin
