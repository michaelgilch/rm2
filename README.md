# rm2

reMarkable2 custom templates

## Creating Templates (using Inkscape)

1. File | Document Properties
    - Format: custom (px)
    - Width: 1404 px
    - Height: 1872 px
    - Scale: 1.0
2. Setup template. Use greyscale
3. Save as SVG
4. Export as PNG with Alpha -> 255 (do not re-save)

## Copying template to reMarkable

```bash
scp ./custom/template_name.*  root@10.11.99.1:/usr/share/remarkable/templates/
```