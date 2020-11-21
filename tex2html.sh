for fn in index
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

for file in content/*.tex
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


for file in content/ads-b/*.tex
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
    --variable rootdir="../../" \
    --variable editat=$fn
done

for file in content/mode-s/*.tex
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
    --variable rootdir="../../" \
    --variable editat=$fn
done


for file in misc/*.tex
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