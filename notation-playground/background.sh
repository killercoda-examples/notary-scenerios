#!/bin/bash
NOTATION_VERSION=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/notaryproject/notation/releases/latest -o /dev/null | sed -e 's|.*/||')

curl -LO https://github.com/notaryproject/notation/releases/download/v$NOTATION_VERSION/notation_$NOTATION_VERSION\_linux_amd64.tar.gz

tar xvzf notation_$NOTATION_VERSION\_linux_amd64.tar.gz -C /usr/bin/ notation

touch /tmp/finished