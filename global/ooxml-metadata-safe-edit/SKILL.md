---
name: ooxml-metadata-safe-edit
description: |
  Edit document properties (author, title, lastModifiedBy) inside .xlsx/.docx/.pptx without
  corrupting the file. Use when: (1) cleaning generator names like "python-docx", "openpyxl",
  "Un-named" out of docProps/core.xml before shipping or selling files; (2) a marketplace or
  client requires "document properties are clean"; (3) you hit
  "Namespace prefix dc on creator is not defined" or "XMLSyntaxError" from lxml/openpyxl on a
  file that opens fine in LibreOffice or Excel; (4) a tool that reads your xlsx suddenly returns
  an error object where it used to return data. Covers the inline-xmlns trap, why a tolerant
  reader hides the breakage, and how to verify by parsing rather than string-matching.
author: Claude Code
version: 1.0.0
date: 2026-08-30
---

# OOXML Metadata Safe Edit

## Problem

`docProps/core.xml` inside an OOXML file looks like trivially patchable XML, so the obvious move is
a regex replace and a `zip` back into the archive. That works on files written by Word and Excel
and **silently corrupts files written by openpyxl and python-docx**, because the two write the
namespace declarations differently.

The corruption is invisible to the readers you are most likely to test with.

## Context / Trigger Conditions

- You are rewriting `docProps/core.xml` to set `dc:creator`, `dc:title`, or `cp:lastModifiedBy`.
- Errors that mean you already hit this:
  - `lxml.etree.XMLSyntaxError: Namespace prefix dc on creator is not defined, line 1, column N`
  - `openpyxl` raising on `load_workbook` for a file that opened yesterday
  - A measurement/parse script storing an `{ error: ... }` object instead of results
- Symptom without an error: LibreOffice and Excel open the file happily while a Python pipeline
  refuses it.

## Solution

### Understand the two shapes

Word/Excel-authored `core.xml` declares every prefix **on the root**:

```xml
<cp:coreProperties xmlns:cp="..." xmlns:dc="http://purl.org/dc/elements/1.1/"
                   xmlns:dcterms="..." xmlns:xsi="...">
  <dc:title>...</dc:title><dc:creator>...</dc:creator>
```

openpyxl-authored `core.xml` declares **only `cp` on the root** and puts the prefix inline
on each element:

```xml
<cp:coreProperties xmlns:cp="...">
  <dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/">openpyxl</dc:creator>
```

So inserting a bare `<dc:creator>ModelStack</dc:creator>` into the second shape produces an
undeclared prefix. It is not well-formed XML, per the XML Namespaces spec: a prefixed name is only
legal where its prefix is bound in scope.

### The safe edit

1. **Guarantee the declarations on the root first**, before writing any prefixed element:

```js
xml = xml.replace(/(<cp:coreProperties\b)([^>]*)>/, (m, open, attrs) => {
  let a = attrs;
  if (!/xmlns:dc\s*=/.test(a))      a += ' xmlns:dc="http://purl.org/dc/elements/1.1/"';
  if (!/xmlns:dcterms\s*=/.test(a)) a += ' xmlns:dcterms="http://purl.org/dc/terms/"';
  if (!/xmlns:xsi\s*=/.test(a))     a += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
  return `${open}${a}>`;
});
```

2. **Match elements whether or not they carry their own xmlns, and collapse duplicates.** A regex
   like `<dc:creator>[\s\S]*?</dc:creator>` will NOT match `<dc:creator xmlns:dc="...">`, so a naive
   replace leaves the original in place and adds a second one:

```js
const setTag = (xml, tag, val) => {
  const any = new RegExp(`<${tag}(?:\\s[^>]*)?\\s*/>|<${tag}(?:\\s[^>]*)?>[\\s\\S]*?</${tag}>`, 'g');
  if (any.test(xml)) { let first = true;
    return xml.replace(any, () => first ? (first = false, `<${tag}>${val}</${tag}>`) : ''); }
  return xml.replace(/(<cp:coreProperties[^>]*>)/, `$1<${tag}>${val}</${tag}>`);
};
```

   Handle three shapes per tag: self-closing (`<dc:title/>`), paired, and absent.

3. **Escape the values.** A product name containing `&` will break the XML you just fixed.

4. **Write it back** by zipping only that entry into the existing archive, preserving the path:
   `cd <tmp> && zip -q "<abs path to docx>" docProps/core.xml`.

## Verification

**Parse the result. Do not string-match it.**

```js
execSync(`python -c "import xml.dom.minidom,sys; xml.dom.minidom.parse(sys.argv[1])" "${tmp}"`);
```

Checking that the output *contains* `<dc:creator>ModelStack</dc:creator>` passes on a file that is
invalid XML — the string is right there, inside the breakage. That exact check is what let this ship.

The stdlib parser is fine here because the input is a file you just generated. If you ever point
this at OOXML from an untrusted source, use `defusedxml` instead — stdlib parsers are exposed to
XXE and entity-expansion attacks.

Then re-run whatever downstream tool consumes the file (a measurement script, `openpyxl.load_workbook`,
a recalc) and confirm it still returns data rather than an error.

## Example

```
Before: <cp:coreProperties xmlns:cp="..."><cp:lastModifiedBy>ModelStack</cp:lastModifiedBy>
        <dc:creator>ModelStack</dc:creator>                      <- undeclared prefix, INVALID
        <dc:creator xmlns:dc="...">openpyxl</dc:creator>         <- the original, still present

After:  <cp:coreProperties xmlns:cp="..." xmlns:dc="..." xmlns:dcterms="..." xmlns:xsi="...">
        <dc:title>Restaurant Financial Model</dc:title>
        <dc:creator>ModelStack</dc:creator>
        <cp:lastModifiedBy>ModelStack</cp:lastModifiedBy>
```

## Notes

- **The dangerous part is the tolerant reader.** LibreOffice opened the corrupted workbooks and a
  full headless recalc passed, all 53 integrity checks TRUE — while lxml and openpyxl refused the
  same file. If two consumers exist, validate with the STRICTER one, or the lenient one becomes an
  accidental accomplice. Generalises well beyond OOXML.
- **A downstream script may swallow the failure.** A measurement wrapper stored the exception as an
  `{error: "..."}` field in its output JSON, so the pipeline looked like it ran. The corruption only
  surfaced when a later consumer crashed on a missing numeric field. Grep your truth/measurement
  outputs for `error` keys after a bulk edit.
- **Prefer regenerating over patching** when the file has a generator. Re-running the generator
  produced valid `core.xml` for free; patching was only needed for files with no source.
- Related but distinct: `<workbookProtection/>` with no attributes locks nothing and needs no fix.
  Do not "clean" it and change a shipped file's hash for no benefit.
- Marketplace context: Flevy's submission checklist explicitly requires "document properties are
  clean", which is usually what sends you here. See `bulk-marketplace-listing`.

## References

- XML Namespaces spec (prefix must be bound in scope): https://www.w3.org/TR/xml-names/
- ECMA-376 Part 2, OPC core properties (`docProps/core.xml`, Dublin Core elements)
- See also: `verify-xlsx-models-libreoffice-recalc` (proving the MODEL is error-free, a different
  question from proving the FILE is well-formed), `xlsx` (authoring spreadsheet content).
