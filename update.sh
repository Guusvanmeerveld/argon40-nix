ARGONDOWNLOADSERVER=https://download.argon40.com

CHECKGPIOMODE=libgpiod

wget $ARGONDOWNLOADSERVER/scripts/argononed.py -O src/argononed.py
wget $ARGONDOWNLOADSERVER/scripts/argonregister.py -O src/argonregister.py
wget $ARGONDOWNLOADSERVER/scripts/argonsysinfo.py -O src/argonsysinfo.py
wget "$ARGONDOWNLOADSERVER/scripts/argonpowerbutton-${CHECKGPIOMODE}.py" -O src/argonpowerbutton.py

