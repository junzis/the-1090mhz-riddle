html:
	./tex2html.sh
	cp _static/*.css _build/html
	cp _build/pdf/book.pdf _build/html/book-the_1090mhz_riddle-junzi_sun.pdf
	cp images/*.svg _build/html/adsb/images/
	sed -i 's/cpr-1\.pdf/cpr-1\.svg/g' _build/html/adsb/compact-position-report.html
	sed -i 's/cpr-2\.pdf/cpr-2\.svg/g' _build/html/adsb/compact-position-report.html

pdf:
	pdflatex -output-directory=/tmp -synctex=1 book.tex
	pdflatex -output-directory=/tmp -synctex=1 book.tex
	mv /tmp/book.pdf _build/pdf/
	mv /tmp/book.synctex.gz _build/pdf/

clean:
	find _build/html/ -type f -delete
	find _build/pdf/ -type f -delete
