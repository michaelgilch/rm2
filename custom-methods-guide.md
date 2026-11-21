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
scp -r root@10.11.99.1:/usr/share/remarkable/templates reference/templates
```

Determine top-level keys of templates:

```bash
jq -r 'keys_unsorted[]' *.template | sort | uniq -c | sort -rn
```
```
	65 templateVersion
	65 orientation
	65 name
	65 items
	65 formatVersion
	65 constants
	65 categories
	65 author
	16 supportedDevices
	 1 iconData
```

Item types and keys:

```bash
jq -r '.. | objects | select(.type? | IN("group","path","text")) | .type + ": " + (keys|join(","))' *.template | sort | uniq -c | sort -rn
```
```
	73 group: boundingBox,children,repeat,type
	67 path: data,type
	60 text: fontSize,position,text,type
	34 path: data,id,type
	29 group: boundingBox,children,id,repeat,type
	11 group: boundingBox,children,type
	 6 path: data,fillColor,type
	 6 path: antialiasing,data,fillColor,strokeWidth,type
	 2 path: data,strokeWidth,type
	 2 group: boundingBox,children,id,type
	 1 path: data,id,strokeWidth,type
	 1 path: data,id,strokeColor,strokeWidth,type
	 1 path: data,fillColor,id,strokeColor,type
```

There are only three item types: group, path, text. Everything a built-in draws is made of those.

Every repeat value:

```bash
jq -c '.. | objects | .repeat? // empty' *.template | sort | uniq -c | sort -rn
```
```
	34 {"rows":"down"}
	 8 {"rows":"infinite","columns":"right"}
	 7 {"rows":5}
	 7 {"rows":2}
	 6 {"rows":"infinite","columns":"infinite"}
	 4 {"rows":"up","columns":"infinite"}
	 4 {"rows":"down","columns":"infinite"}
	 4 {"rows":6}
	 4 {"rows":3}
	 3 {"rows":"rowCount"}
	 3 {"rows":4}
	 3 {"columns":"infinite","rows":"infinite"}
	 2 {"rows":"up"}
	 2 {"rows":8}
	 2 {"columns":"infinite","rows":"up"}
	 2 {"columns":"infinite","rows":"down"}
	 2 {"columns":2,"rows":2}
	 1 {"rows":"infinite"}
	 1 {"rows":19}
	 1 {"rows":17}
	 1 {"columns":"columns","rows":5}
	 1 {"columns":2}
```

Path commands, colors, line widths, font sizes:

```bash
jq -r '.. | objects | select(.type=="path") | .data[] | strings | select(test("^[A-Za-z]$"))' *.template | sort | uniq -c
jq -r '.. | objects | (.strokeColor?, .fillColor?) // empty' *.template | sort | uniq -c
jq -r '.. | objects | .strokeWidth? // empty' *.template | sort | uniq -c
jq -r '.. | objects | .fontSize? // empty' *.template | sort -n | uniq -c
```
```
Paths: M,L,C, and Z
Colors: #000000 and #ffffff
Stroke widths: 1 and 2
Font sizes: 24, 25, 32, and 72
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


