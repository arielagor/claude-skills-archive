---
name: sign-and-flatten-pdf
description: |
  Sign, date, flatten and PROVE a filled PDF form before returning it to whoever
  asked for it. Use when: (1) a filled form needs a handwritten-signature image and
  a date stamped into cells that are NOT form fields (IRS W-9/W-4/W-8BEN-E, vendor
  onboarding packets, NDAs, insurance ACORDs, USPTO forms); (2) a form must be
  flattened so the recipient cannot edit it; (3) a verification says a field is
  EMPTY or WRONG on a form that is visibly correct, especially a TIN/SSN/EIN or any
  boxed one-character-per-cell field; (4) a signature image renders as a black or
  white BOX over the document; (5) you need to prove a form is correct rather than
  assert it. Covers the comb-field false-red, the no-alpha-channel signature trap
  that a mean-alpha check passes, PyMuPDF doc.bake(), and metadata that survives.
  Does NOT cover mapping or filling the fields themselves: the `pdf` skill and its
  FORMS.md own that, run it first and come here for the last mile.
author: Claude Code
version: 1.0.0
date: 2026-09-09
---

# Sign and Flatten a PDF Form

## Problem

Form tooling stops at "the field values are set". A form that gets **returned to a
human** needs three more things, and each has a trap that fails silently:

1. **Ink where there is no field.** Signature and date lines on government forms are
   almost never AcroForm fields. They are printed cells. Nothing will tell you this;
   `extract_form_field_info.py` simply will not list them.
2. **A flatten**, so the recipient cannot alter what was certified.
3. **A readback that can actually fail.** The obvious readback is the one that lies.

## Context / Trigger Conditions

Reach for this when any of these is true:

- A form is filled and now has to be signed, dated, and sent.
- A verification reports a field empty or wrong, but a rendered image of the page
  shows it filled correctly. Near-certainly a comb field (see below).
- A signature image appears as a solid black or white rectangle in a sent email,
  deck, or filing.
- Someone asks you to confirm a form is correct before it goes out.

**Run the `pdf` skill first.** `pdf/FORMS.md` maps fields, distinguishes fillable
from non-fillable, and fills them. This skill is only the last mile after that.

## Solution

```bash
python ~/.claude/skills/sign-and-flatten-pdf/scripts/sign_and_flatten.py \
    filled.pdf spec.json signed.pdf
```

The script's docstring carries the full spec format. It stamps images and text,
flattens, preserves metadata, then reopens the **saved file** and verifies. Exit 0
means every check passed. Any non-zero means do not send the file.

### Trap 1: comb fields make a correct form look broken

TIN, SSN, EIN, date and account-number boxes are **comb fields** (`Ff` bit 25,
`/MaxLen` set): one character per printed cell. PyMuPDF fills them correctly, but
writes **each character as a separately positioned glyph**. So:

```python
"1586449" in page.get_text()   # False, on a perfectly filled form
```

A substring assertion against a comb field is a **false red**, and it will send you
debugging a bug that does not exist. Read it back by x-position instead, which the
helper's `comb` verifier does.

**The second half of that trap:** the band you select also contains the form's own
printed furniture. Reading every glyph in the EIN band returned `46>1586449` for a
correct EIN, and `or>>` for an SSN row that was **empty**. Filter to the charset the
field can hold (`"chars": "digits"` is the default, `"alnum"` and `"any"` also work,
or pass your own regex).

Always assert the boxes you deliberately left blank ARE blank. "I removed the SSN"
is otherwise an unverified claim, and on a tax form that claim matters.

### Trap 2: the alpha check that passes the worst file

The standing rule is that a signature must be true transparent alpha, never
flattened onto black or white, because it gets attached to documents with different
backgrounds. The usual verification is `magick identify -format "%[fx:mean.a]"`,
expecting ~0.04 rather than 1.0.

**That check is incomplete and passes the most dangerous file.** Three states:

| `%A` | `mean.a` | Meaning |
|---|---|---|
| `Blend` | ~0.04 | genuinely transparent, good |
| `Blend` | 1.0 | has a channel, fully opaque, renders as a box |
| `Undefined` | **0** | no alpha channel at all, renders as a box |

An image with **no alpha channel reports mean 0, not 1**, so a mean-only test reads
it as the healthiest possible file. Verified 2026-09-09: a `-alpha remove` PNG
sailed through a `mean >= 0.99` guard. Check `%A` first, then the mean. The helper
refuses both bad states with a specific message.

### Trap 3: metadata

`doc.set_metadata({...})` with a bare dict **replaces** the whole dictionary and
leaves `/Creator` as a `NullObject`, which some validators read as corruption. Carry
the source forward: `meta = doc.metadata or {}; meta.update({...})`.

### Coordinates

The helper uses PyMuPDF page coordinates, origin **top-left**, y growing downward.
`pypdf` and `pdfplumber` report PDF-native coordinates, origin **bottom-left**.
Convert with `y_fitz = page_height - y_pdf`. Mixing them puts the signature
somewhere confidently wrong, so print `page.rect` and sanity-check.

To find an unfielded signature cell, read the page's drawn rules and the label
positions:

```python
for d in page.get_drawings():           # the box the signature sits in
    print(d["rect"])
for w in page.get_text("words"):        # where the caption ends
    print(w[:4], w[4])
```

## Verification

Never claim a form is signed on a clean exit. The helper's exit code is the claim,
and it is only meaningful because the failure paths were proven to fire. On Form W-9
(Rev. March 2024), 2026-09-09:

| Control | Result |
|---|---|
| Correct form, correct expectations | exit 0, 8 checks passed |
| Wrong expected EIN | exit 1, `expected '999999999', read '461586449'` |
| Claim a value in the empty SSN row | exit 1, `expected '123456789', read ''` |
| Expect text that is not on the form | exit 1, `expected text missing` |
| Signature PNG with no alpha channel | exit 1, refused before writing |
| Signature PNG opaque with a channel | exit 1, refused before writing |

Also render the region and look at it, because a passing assertion still does not
prove the ink is in the right *place*:

```python
page.get_pixmap(clip=fitz.Rect(30, 560, 590, 610), dpi=260).save("check-sig.png")
```

**Beware the pipe.** `script.py | grep -v noise; echo $?` reports **grep's** exit
code, not the script's. This bit twice while testing this very helper. Redirect
instead: `script.py >/dev/null 2>&1; echo $?`.

## Example

Signing a W-9 whose fields are already filled:

```json
{
  "stamps": [
    {"type": "image", "page": 1, "path": "~/.claude/brand/ariel-signature.png",
     "rect": [135, 577.5, 201.4, 598.5], "trim_alpha": true},
    {"type": "text", "page": 1, "text": "09/09/2026", "at": [420, 592], "fontsize": 10}
  ],
  "flatten": true,
  "metadata": {"title": "Form W-9 (Rev. March 2024)", "author": "Ariel Agor"},
  "verify": {
    "text_present": ["Ariel Agor", "SANSPNASH"],
    "comb": [
      {"name": "EIN", "page": 1, "y": [420, 445], "x_min": 415, "expect": "461586449"},
      {"name": "SSN", "page": 1, "y": [372, 397], "x_min": 415, "expect": ""}
    ]
  }
}
```

`trim_alpha` runs `-channel A -level 10%,100% +channel -trim +repage`, which floors
the soft glow so it does not haze a white form and crops dead margin so the rect you
give is the ink you get.

## Notes

- **Get the form from the issuer every time.** `https://www.irs.gov/pub/irs-pdf/fw9.pdf`
  and siblings. A revision change renames every field, so a cached field map is a
  liability.
- Signature placement is constrained by the cell. A W-9 signature box is 24pt tall,
  so a compact mark ends up ~66pt wide. That is correct, not small.
- See also: `pdf` (and its `FORMS.md`) for mapping and filling, which this skill
  deliberately does not duplicate; `file-provisional-patent` for USPTO Patent Center
  specifically; `ooxml-metadata-safe-edit` for the same class of metadata problem in
  Office files.
- Ariel-specific: the transparent signature master is
  `~/.claude/brand/ariel-signature.png`, the standing authorization to apply it is in
  memory `feedback_ariel_s_signature_authorization`, and the settled W-9 answers plus
  the full Rev. 3-2024 field map are in `reference_fill_sign_acroform_pdf_pymupdf`.

## References

- [IRS Form W-9](https://www.irs.gov/pub/irs-pdf/fw9.pdf) (Rev. March 2024)
- [PyMuPDF: Widget / form handling](https://pymupdf.readthedocs.io/en/latest/widget.html)
- [PyMuPDF `Document.bake()`](https://pymupdf.readthedocs.io/en/latest/document.html#Document.bake)
- [ImageMagick format escapes](https://imagemagick.org/script/escape.php) (`%A`, `%[fx:mean.a]`)
