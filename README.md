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

# MAJOR OVERHALL

**As of v3.30, custom templates are no longer functioning.**

It looks like the built-in templates have been moved to .template files in `/usr/share/remarkable/templates`. Anything copied there before 3.30 is ignored.
The .template files are JSON descriptions

It looks like you can add custom templates as "Methods" (`.template` + `.content` + `.metadata`) in `/home/root/.local/share/remarkable/xochitl/`.

The content of the 3 files was determined by poking around in the existing template files and a few added Methods.

The filenames needs to be a UUID for it to display in the web app correctly. You can create a UUID with:

```bash
python3 -c 'import uuid; print(uuid.uuid4())'
```

The `.content` file is an empty JSON, which can be generated with:

```bash
printf '{\n}\n' > $UUID.content
```
