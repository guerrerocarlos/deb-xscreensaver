#!/bin/sh
# Check our desktop files and compare them to upstream xml files
# TODO: actually generate the desktop files
# 2007 Tormod Volden

# Some xml files are for external programs or hacks that are not built
# we do not ship desktop files for those
EXTERNALS="\
 cosmos \
 dnalogo \
 electricsheep \
 fireflies \
 goban \
 rdbomb \
 sphereeversion \
 xaos \
 xdaliclock \
 xmountains \
 xplanet \
 xsnow \
 xteevee \
"

# Poor man's xml parser "can i haz xml purrser"
get_xml_option () {
	file=$1
	tag=$2
	option=$3

	sed -n '/\<'$tag' /s@.* '$option'="\([^"]*\)".*@\1@p' < $file
}


for XML in hacks/config/*.xml; do
  NAME=`basename $XML .xml`
  DSK=debian/screensavers-desktop-files/${NAME}.desktop

  if echo $EXTERNALS | grep -wq $NAME; then
	if [ -f $DSK ]; then
		echo " external $NAME has a desktop file"
	fi
	continue
  fi

  if [ ! -f hacks/${NAME}.c  ] &&
     [ ! -f hacks/glx/${NAME}.c ] &&
     [ ! -f hacks/${NAME} ]
  then
	echo " no c source or script file for $NAME"
  fi

  if [ ! -f hacks/${NAME}.man  ] &&
     [ ! -f hacks/glx/${NAME}.man ]
  then
	echo " no man page for $NAME"
  fi

  if [ ! -f $DSK ]; then
	echo " missing $DSK file"
	continue
  fi

  XMLNAME=`get_xml_option $XML screensaver name`
  XMLARG=`get_xml_option $XML command arg | sed 'N; s/\n/ /'` 
  XMLEXE="$XMLNAME $XMLARG"
  DSKEXE=`sed -n '/^Exec=/s@Exec=@@p' < $DSK`
  if [ x"$XMLEXE" = x ] || [ x"$DSKEXE" = x ] || [ x"$XMLEXE" != x"$DSKEXE" ]; then
	echo " exec not matching: $XMLEXE and $DSKEXE"
  fi

  XMLLABEL=`get_xml_option $XML screensaver _label`
  DSKNAME=`sed -n '/^Name=/s@Name=@@p' < $DSK`
  if [ x"$XMLLABEL" = x ] || [ x"$DSKNAME" = x ] || [ x"$XMLLABEL" != x"$DSKNAME" ]; then
	echo " name not matching: $XMLLABEL and $DSKNAME"
  fi

  DSKTRY=`sed -n '/^TryExec=/s@TryExec=@@p' < $DSK`
  if [ x"$XMLNAME" = x ] || [ x"$DSKTRY" = x ] || [ x"$XMLNAME" != x"$DSKTRY" ]; then
	echo " tryexec name not matching: $XMLNAME and $DSKTRY"
  fi
 
done
