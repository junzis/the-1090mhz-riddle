html:
	make pdf
	bash tex2html.sh
	cp _static/*.css _build/html/
	pdftk A=_build/pdf/book.pdf B=cover/front.pdf C=cover/back.pdf cat B1 A2-end C1 output _build/html/book-the_1090mhz_riddle-junzi_sun.pdf

pdf:
	pdflatex -output-directory=/tmp -synctex=1 book.tex
	biber /tmp/book
	pdflatex -output-directory=/tmp -synctex=1 book.tex
	mv /tmp/book.pdf _build/pdf/book.pdf
	mv /tmp/book.synctex.gz _build/pdf/book.synctex.gz


clean:
	find _build/html/ -type f -delete
	find _build/pdf/ -type f -delete
