.PHONY: website serve

website:
	pandoc --standalone \
         --from commonmark_x+alerts \
         --output=website/index.html \
         --template=pandoc/template.html4 \
         --css=style.css \
         --toc \
         --toc-depth=1 \
         --resource-path=. \
         --lua-filter=pandoc/paper.lua \
         --lua-filter=pandoc/date.lua \
         --lua-filter=pandoc/diagram.lua \
         --extract-media=website \
         src/index.md

serve: website
	cd website && python -m http.server 8000
