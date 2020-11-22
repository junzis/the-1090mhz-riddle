for fn in index
do
  pandoc index.tex \
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
    --variable editat=$fn \
    --extract-media _build/html/figures
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
    --variable editat=$fn \
    --extract-media _build/html/figures
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
    --variable editat=$fn \
    --extract-media _build/html/figures
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

find _build/html/content/ -name '*.html' -exec sed -i 's/embed\(.*\)pdf/img\1png/g' {} \;

find _build/html/content/ads-b/ -maxdepth 1 -name '*.html' -exec sed -i 's/_build\/html/\.\.\/\.\./g' {} \;
find _build/html/content/mode-s/ -maxdepth 1 -name '*.html' -exec sed -i 's/_build\/html/\.\.\/\.\./g' {} \;
find _build/html/content/ -maxdepth 1 -name '*.html' -exec sed -i 's/_build\/html/\.\./g' {} \;

cd _build/html/figures/
for pdf_file in *.pdf ; do
  echo "converting ${pdf_file}"
  convert -density 100 "${pdf_file}" -colorspace RGB "${pdf_file%.*}".png
  rm ${pdf_file}
done