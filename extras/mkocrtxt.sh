#!/bin/sh
# See COPYING file for copyright and license details.
#
# Makes a text file with text extracted by tesseract
# Requires imagemagick and tesseract
#
# Note: Unfortunately tesseract works much better if one first
#       makes the image to be OCRed significantly larger. This
#       script therefore temporarily creates a larger file to
#       feed to tesseract. These temporary large files are also
#       converted to tiff format, so that they're readable by
#       any version of tesseract.

test $# -ne 1 && echo "Usage: $0 bookdir" && exit 1
cd "$1" || exit 1

for i in `ls`
do
	echo "$i"

	# create a much bigger version of the page image
	width=`identify "$i" | awk '{print $3}' | sed 's/x.*//'`
	bigwidth=`expr $width \* 4`
	convert "$i" -geometry ${bigwidth}x "$i.big.tif"

	# scan the page image
	tesseract "$i.big.tif" "$i" 2>&1 | sed '/Tesseract Open Source OCR Engine/d'

	# combine the page text with the rest of the book
	cat "$i.txt" >> book.txt

	# remove working files
	rm -f "$i.big.tif" "$i.txt"
done

echo "$1/book.txt"
