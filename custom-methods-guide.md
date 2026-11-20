# Custom Methods Guide

This guide explains my findings around creating custom "Methods" for reMarkable
tablets after v3.30 broke the SVG template versions I previously deployed.

## Overview

## Template Locations

Templates are now stored in 2 locations:

- `/usr/share/remarkable/templates/` houses the 65 built-in templates, referred
	to as **Templates** from here on.
- `/home/root/.local/share/remarkable/xochitl/` houses the new **Methods** 
	format of templates alongside all of your notebooks. These will be referred
	to as **Methods** from here on.

## Templates

The same 65 built-in templates exist after the 3.30 update, but are now JSON 
descriptions rather than SVG files.

Copies of the built-in templates can be pulled using the following:

```bash
mkdir -p reference/templates/
scp -r root@10.11.99.1:/usr/share/remarkable/templates reference/templates/
```

## Methods

Methods are named by UUID just like notebooks, and reside in the same notebook
store. Each Method has a **.template** file, just like the original built-in 
templates. consists of 4 files each, with matching UUIDs.

- **<UUID>.content**: 
- **<UUID>.metadata**: 
- **<UUID>.template**:
- **<UUID>.thumbnails/**: 

Copies of any Methods downloaded to the tablet can be pulled using the following:

```bash
mkdir -p reference/methods/
XDIR=/home/root/.local/share/remarkable/xochitl
for id in $(ssh root@10.11.99.1 "cd $XDIR && grep -l '\"TemplateType\"' *.metadata | sed 's/\.metadata$//'"); do
	scp -r "root@10.11.99.1:$XDIR/$id.*" reference/methods/
```
