for file in index adsb ehs
do
  pandoc $file.tex \
    --output _build/html/$file.html \
    --template _static/template.html5 \
    --css bootstrap.min.css \
    --css style.css \
    --toc \
    --toc-depth=3 \
    --mathjax
done

for file in adsb/*.tex
do
  fbase=${file%.tex}
  pandoc $file \
    --output _build/html/$fbase.html \
    --template _static/template.html5 \
    --css bootstrap.min.css \
    --css style.css \
    --toc \
    --toc-depth=3 \
    --mathjax \
    --variable rootdir='../'
done

for file in ehs/*.tex
do
  fbase=${file%.tex}
  pandoc $file \
    --output _build/html/$fbase.html \
    --template _static/template.html5 \
    --css bootstrap.min.css \
    --css style.css \
    --toc \
    --toc-depth=3 \
    --mathjax \
    --variable rootdir='../'
done
