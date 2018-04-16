for fn in index adsb ehs
do
  pandoc $fn.tex \
    --output _build/html/$fn.html \
    --template _static/template.html5 \
    --css bootstrap.min.css \
    --css style.css \
    --toc \
    --toc-depth=3 \
    --mathjax \
    --variable editat=$fn
done

for file in adsb/*.tex
do
  fn=${file%.tex}
  pandoc $file \
    --output _build/html/$fn.html \
    --template _static/template.html5 \
    --css bootstrap.min.css \
    --css style.css \
    --toc \
    --toc-depth=3 \
    --mathjax \
    --variable rootdir="../" \
    --variable editat=$fn
done

for file in ehs/*.tex
do
  fn=${file%.tex}
  pandoc $file \
    --output _build/html/$fn.html \
    --template _static/template.html5 \
    --css bootstrap.min.css \
    --css style.css \
    --toc \
    --toc-depth=3 \
    --mathjax \
    --variable rootdir="../" \
    --variable editat=$fn
done
