ARGONDOWNLOADSERVER=https://download.argon40.com

CHECKGPIOMODE=libgpiod

SOURCE_DIR=src

WGET_OPTS="--quiet"

echo "Downloading Python source files..."

wget $ARGONDOWNLOADSERVER/scripts/argononed.py -O $SOURCE_DIR/argononed.py $WGET_OPTS
wget $ARGONDOWNLOADSERVER/scripts/argoneond.py -O $SOURCE_DIR/argoneond.py $WGET_OPTS
wget $ARGONDOWNLOADSERVER/scripts/argonrtc.py -O $SOURCE_DIR/argonrtc.py $WGET_OPTS
wget $ARGONDOWNLOADSERVER/scripts/argonregister.py -O $SOURCE_DIR/argonregister.py $WGET_OPTS
wget $ARGONDOWNLOADSERVER/scripts/argonsysinfo.py -O $SOURCE_DIR/argonsysinfo.py $WGET_OPTS
wget $ARGONDOWNLOADSERVER/scripts/argoneonoled.py -O $SOURCE_DIR/argoneonoled.py $WGET_OPTS
wget "$ARGONDOWNLOADSERVER/scripts/argonpowerbutton-${CHECKGPIOMODE}.py" -O $SOURCE_DIR/argonpowerbutton.py $WGET_OPTS

echo "Downloading install scripts..."

wget $ARGONDOWNLOADSERVER/argon1.sh -O $SOURCE_DIR/installers/argon1.sh $WGET_OPTS
wget $ARGONDOWNLOADSERVER/argoneon.sh -O $SOURCE_DIR/installers/argoneon.sh $WGET_OPTS

echo "Downloading OLED bin files..."

for binfile in font8x6 font16x12 font32x24 font64x48 font16x8 font24x16 font48x32 bgdefault bgram bgip bgtemp bgcpu bgraid bgstorage bgtime
do
	wget $ARGONDOWNLOADSERVER/oled/${binfile}.bin -O $SOURCE_DIR/oled/${binfile}.bin $WGET_OPTS
done

