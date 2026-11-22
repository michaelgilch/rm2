# Custom Methods Guide

This guide explains my findings around creating custom "Methods" for reMarkable
tablets after v3.30 broke the SVG template versions I previously deployed.

Templates are now stored in 2 locations:

- `/usr/share/remarkable/templates/` houses the 65 built-in templates, referred
	to as **Templates** from here on.
- `/home/root/.local/share/remarkable/xochitl/` houses the new **Methods** 
	format of templates alongside all of your notebooks. These will be referred
	to as **Methods** from here on.

## Built-in Templates

The same 65 built-in templates exist after the 3.30 update, but are now JSON 
descriptions rather than SVG files.

Copies of the built-in templates can be pulled using the following:

```bash
mkdir -p reference/templates/
scp -r root@10.11.99.1:/usr/share/remarkable/templates reference/templates
```

Poking around with `jq`...

```bash
# Top level keys
jq -r 'keys_unsorted[]' *.template | sort | uniq -c | sort -rn

# Items and types
jq -r '.. | objects | select(.type? | IN("group","path","text")) | .type + ": " + (keys|join(","))' *.template | sort | uniq -c | sort -rn

# Repeat values
jq -c '.. | objects | .repeat? // empty' *.template | sort | uniq -c | sort -rn

# Path commands
jq -r '.. | objects | select(.type=="path") | .data[] | strings | select(test("^[A-Za-z]$"))' *.template | sort | uniq -c

# Colors
jq -r '.. | objects | (.strokeColor?, .fillColor?) // empty' *.template | sort | uniq -c

# Widths
jq -r '.. | objects | .strokeWidth? // empty' *.template | sort | uniq -c

# Fonts
jq -r '.. | objects | .fontSize? // empty' *.template | sort -n | uniq -c
```

- Every file has the same eight top-level keys: **name**, **author**, 
	**templateVersion**, **formatVersion**, **categories**, **orientation**, 
	**constants**, and **items**.
- 16 of the 65 files also list **supportedDevices** (rm2, rmPP).
- One has an **iconData** key, and its value is "None".
- There are only 3 building blocks. Everythign is drawn with **group**, **path**,
	and **text**. 115 groups, 118 paths, and 60 text items across the 65 files.
- Groups position and repeat things. Paths draw lines and shapes.
- Most groups repeat. Ruled line templates use **"rows": "down"**. Grids and dots
	repeat in all directions with **infinite**, and checklists use a fix count.
- Drawing vocab is small: **M** (move), **L** (line), **C** (curve), **Z** (end).
- Colors are only black and white.
- **strokeWidth** is always 1 or 2 and is rarely changed.
- Text uses 4 font sizes: 24, 25, 32, and 72.
- Values can be expressed. Many numbers are strings: "templateWidth / 2 - templateHeight / 2".
- Most expressed names are defined in the files **constants** key. Some are 
	defined nowhere so must be built-in (**templateWidth**, **templateHeight**, 
	**parentWidth**, **parentHeight**, **textWidth**, **paperOriginX**).

---

## Method Templates

Methods are named by UUID just like notebooks, and reside in the same notebook
store. Each Method has a **.template** file, just like the original built-in 
templates. consists of 4 files each, with matching UUIDs.

- **<UUID>.content**: An empty JSON object.
- **<UUID>.metadata**: Name and document type info.
- **<UUID>.template**: The drawing, as JSON.
- **<UUID>.thumbnails/**: Decoded `iconData`, created by the tablet.

Copies of any Methods downloaded to the tablet can be pulled using the following:

```bash
mkdir -p reference/methods/
XDIR=/home/root/.local/share/remarkable/xochitl
for id in $(ssh root@10.11.99.1 "cd $XDIR && grep -l '\"TemplateType\"' *.metadata | sed 's/\.metadata$//'"); do
	scp -r "root@10.11.99.1:$XDIR/$id.*" reference/methods/
```

- Methods differ in structure by always having an **iconData** key that points
	to a base64-encoded SVG.
- **templateVersion** values are `1.0.1` in the couple methods I use.

## .metadata

```json
{
	"createdTime": "1793714973468",
	"lastModified": "1793714973468",
	"new": false,
	"parent": "",
	"pinned": false,
	"source": "com.remarkable.methods",
	"type": "TemplateType",
	"visibleName": "Engineering paper"
}
```

- `createdTime` and `lastModified` are millis since 1970, as strings.
- `TemplateType` makes the document a template. Notebooks are `DocumentType`, 
	and folders are `CollectionType`.

## .template

### Coordinates

- **rm2** (reMarkable2) and **rmPP** (Paper Pure) are both 1404 x 1872, 226 ppi.
- The origin is the top-left corner.

### Constants

```json
"constants": [
    {"mobileMaxWidth": 1000},
    {"mobileOffsetY": 160},
    {"magicOffsetY": 0},
    {"offsetY": "templateWidth > mobileMaxWidth ? magicOffsetY : mobileOffsetY"}
]
```

The following names seem to be supplied by the tablet, as they are not in any of
the json-defined constants.

- `templateWidth`, `templateHeight` - The page size in pixels.
- `parentWidth`, `parentHeight` - The enclosing group's boundingBox width and height.

### Items

**`group`** positions children.

- `boundingBox`: `{x, y, width, height}` - Children are drawn with x, y as their
	origin and see width and height as `parentWidth` and `parentHeight`.
- `repeat` takes rows and columns. See below.
- `children` - items, including nesting.

**`repeat`**

- `"rows": "down"` - example: even ruled templates
- `"rows": "infinite", "columns": "infinite"` - example: grids, dots
- `"columns": "right"` - example: grid margin

**`path`** draws a shape.

- `data` - SVG-style commands in a flat list, with coordinates relative to the group.
	`M` (move), `L` (line), `C` (curve), `z` (end)
- `strokeWidth` in pixels.
- `strokeColor` in hex. Built-ins only use black and white.
- `fillColor` fills a closed path.

**`text`**

- `text` - the string
- `fontSize`
- `position` - `{x, y`
- `bold`

