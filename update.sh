ARGONDOWNLOADSERVER=https://download.argon40.com

CHECKGPIOMODE=libgpiod

SOURCE_DIR=src

wget $ARGONDOWNLOADSERVER/scripts/argononed.py -O $SOURCE_DIR/argononed.py
wget $ARGONDOWNLOADSERVER/scripts/argonregister.py -O $SOURCE_DIR/argonregister.py
wget $ARGONDOWNLOADSERVER/scripts/argonsysinfo.py -O $SOURCE_DIR/argonsysinfo.py
wget "$ARGONDOWNLOADSERVER/scripts/argonpowerbutton-${CHECKGPIOMODE}.py" -O $SOURCE_DIR/argonpowerbutton.py

wget $ARGONDOWNLOADSERVER/argon1.sh -O $SOURCE_DIR/installers/argon1.sh
wget $ARGONDOWNLOADSERVER/argoneon.sh -O $SOURCE_DIR/installers/argoneon.sh

