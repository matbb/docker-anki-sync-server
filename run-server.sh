#!/bin/sh
# Alpine linux's shell is sh, not bash !

set -o nounset 
set -o errexit

set -x

ANKI_SERVER_URL="${ANKI_SERVER_URL:-"https://github.com/dsnopek/anki-sync-server.git"}"
ANKI_SERVER_VCS_SRC="${ANKI_SERVER_VCS_SRC:-"branch"}"
ANKI_SERVER_BRANCH="${ANKI_SERVER_BRANCH:-"master"}"
ANKI_SERVER_TAG="${ANKI_SERVER_TAG:-"2.0.6"}"

# Download and install anki-server 
echo "Cloning anki server from ${ANKI_SERVER_URL}"
cd /anki/server 
git clone --recursive "${ANKI_SERVER_URL}" . || :
git submodule update --recursive --remote || :

if [ "$ANKI_SERVER_VCS_SRC" == "branch" ]
then 
        git pull origin "$ANKI_SERVER_BRANCH"
	git checkout "$ANKI_SERVER_BRANCH"
else
        git pull origin "$ANKI_SERVER_BRANCH"
	git checkout "tags/${ANKI_SERVER_TAG}"
fi
git submodule update
# Install bundled anki library
cd anki-bundled ;
make ;
make install||: ;

cd ..
python setup.py egg_info
python setup.py install

export PATH=/anki/server:$PATH
if [ ! -f "/anki/data/production.ini" ]
then 
	cp /anki/production.ini /anki/data/production.ini
fi

# Start and run the server
cd /anki/data
ankiserverctl.py debug
# /usr/bin/python /usr/local/bin/paster serve production.ini
