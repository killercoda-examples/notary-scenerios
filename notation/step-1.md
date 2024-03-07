## Prerequisite

This tutorial already have Docker installed if you unfamiliar with it or want to install it your self vist [Docker Docs](https://docs.docker.com/) for more info.

## Installing

To install Notary you can either build it from source or download pre-build release from Github.

We are going to it install it from from Github.

## Setting Environment variable

To the version of notation you want to download. The current latest version is `1.0.0-rc.7` so we are going to set it for downloading same version.

```
export NOTATION_VERSION=1.1.0
```{{exec}}

### Downloading Notation CLI

There are different version of `ARM` and `x86` processor's. As we are on `x86` platform we are going to use `x86` version curl we download the Notation CLI and also check it checksum.

```
curl -LO https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/notation_$NOTATION_VERSION\_linux_amd64.tar.gz
```{{exec}}

#### Verify Checksum

To confirm that binary is downloaded fine.

```
curl -LO https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/notation_$NOTATION_VERSION\_checksums.txt
shasum --check notation_$NOTATION_VERSION\_checksums.txt | grep "notation_$NOTATION_VERSION\_linux_amd64.tar.gz"
```{{exec}}

### Installing Notation 

```
tar xvzf notation_$NOTATION_VERSION\_linux_amd64.tar.gz -C /usr/bin/ notation
```{{exec}}

### Verify install 

```
notation version
```{{exec}}

> Congratulations you have successfully installed notation cli you now move to next step!
