#!/usr/bin/bash

PUBDIR=${PUBDIR:-"../apache-publish"}
if [ -z "${SRCDIR}" ] ; then SRCDIR="$PWD"; fi

if cd ${PUBDIR} ; then
  echo Copying from ${SRCDIR}/docbuild/html
else
  echo Publish respository \'${PUBDIR}\' not found.
  exit 1
fi

git pull

rm -rf *
cp -r ${SRCDIR}/docbuild/html/* .
cp -r ${SRCDIR}/docbuild/html/.nojekyll .
cp -r ${SRCDIR}/docbuild/html/.buildinfo .
git add *
git commit --message "Update" && git push
