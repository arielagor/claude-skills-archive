---
name: bulk-marketplace-listing
description: |
  Publish an entire product catalog to a third-party marketplace whose vendor portal is a
  WordPress/EDD (or similar CMS) form, without driving the media modal once per product.
  Use when: (1) listing 10+ products/documents on a vendor marketplace like eFinancialModels,
  Flevy, Creative Market, or any WP-based seller portal; (2) a vendor form makes you click
  through a WordPress media uploader for every file and it would take 15 tool calls per item;
  (3) you need per-listing copy generated from measured facts rather than marketing text;
  (4) a marketplace has a PRICE PARITY clause and your prices must match your own site exactly.
  Covers the hidden-attachment-ID shortcut, the exposed wpApiSettings REST nonce, batch media
  upload, localStorage-staged payloads across navigations, and the validation traps that
  silently discard a submission.
author: Claude Code
version: 1.0.0
date: 2026-08-30
---

# Bulk Marketplace Listing

## Problem

Vendor marketplaces built on WordPress + Easy Digital Downloads present a heavy product form:
a TinyMCE editor, a WordPress media modal per file, a deep category/tag taxonomy, and separate
repeater rows for price options and downloadable files. Driven naively that is ~15 browser
actions per product. For a 15-product catalog that is 225 actions, most of them fighting a modal.

It is also the kind of task where a silent validation failure loses everything you just typed.

## Context / Trigger Conditions

- A vendor/seller portal at `/vendor-dashboard`, `/account/upload`, or similar, on a WordPress site.
- The page has `input[name="featured_image"]`, `epv_mp_files[...]`, `download_category[]`,
  `download_tag[]`, or an `.fes-ajax-form` / `fes-submission-form` class.
- Clicking "Upload" opens a `.media-modal` and a plupload `input[type=file]` appears with an id
  like `html5_1k1a...`.
- You are about to write a loop that opens that modal once per product. Stop and read on.

## Solution

### 1. Find the seams before automating anything

Dump every form control with its resolved label once, and keep the `name` attributes:

```js
[...document.querySelectorAll('input,textarea,select')].map(e => ({
  name: e.name, type: e.type, id: e.id,
  lab: (e.parentElement?.innerText || '').trim().slice(0, 60)
})).filter(f => f.name);
```

Two things usually fall out:

- **`featured_image` is a plain hidden input holding only an attachment ID.** So is
  `epv_mp_files[0][attachment_id]`, with a sibling `[url]` text field. You never need the media
  picker to *assign* a file, only to *upload* it.
- **`wpApiSettings.nonce` is exposed on the page.** That means `/wp-json/wp/v2/media` is queryable
  from page JS with `{'X-WP-Nonce': wpApiSettings.nonce}`, which is how you read back the
  attachment ids and urls of whatever you just uploaded.

### 2. Upload every asset in ONE modal pass

Open the media modal once, then strip the input's restrictions and push the whole catalog:

```js
[...document.querySelectorAll('input[type=file]')]
  .forEach(i => { i.removeAttribute('accept'); i.setAttribute('multiple','multiple'); });
```

Then a single `file_upload` call with an array of paths (respect the tool's ~10MB per-call cap;
split into two calls if needed). Wait, then read the ids back:

```js
const res = await fetch('/wp-json/wp/v2/media?per_page=60&orderby=date&order=desc',
  { credentials:'include', headers: { 'X-WP-Nonce': wpApiSettings.nonce } }).then(r => r.json());
res.map(m => `${m.id}|${m.source_url.split('/').pop()}`);
```

**Record the returned filename, not the one you sent.** WordPress deduplicates by appending
`-1`, and converts PNG to JPG. `lbo_model.xlsx` can land as `lbo_model-1.xlsx`.

### 3. Stage payloads and the fill routine in localStorage

Each product submission navigates, which destroys `window` state. `localStorage` survives
same-origin navigation, so pay the payload cost once:

```js
localStorage.setItem('seed', JSON.stringify(ALL_PAYLOADS));
localStorage.setItem('fillSrc', '<the fill function source as a string>');
```

Then every per-product step is tiny:

```js
eval(localStorage.getItem('fillSrc'));
const r = window.fill(i);
document.querySelector('input[type=submit][name="submit_upload"]').click();
```

That is ~2 calls per product instead of ~15.

### 4. Set the rich-text editor through its API, not the textarea

```js
if (typeof tinymce !== 'undefined' && tinymce.get('post_content')) {
  tinymce.get('post_content').setContent(html);
  tinymce.get('post_content').save();   // save() syncs back to the underlying textarea
}
```

Without `.save()` the textarea stays empty and the post body submits blank.

### 5. Fire events after every programmatic value set

```js
const fire = e => ['input','keyup','change'].forEach(t => e.dispatchEvent(new Event(t, {bubbles:true})));
```

Setting `.value` directly does not notify listeners. Live-validators and character/word counters
will read zero and can block or clear your submission. (Flevy's word counter reported
"Word count: 0" on a 457-word description until an `input` event was dispatched.)

## Verification

- Enumerate the vendor product list fresh and **handle pagination** — a heading that says
  "Documents You Listed (20)" over a table rendering 18 is not evidence. Look for a pager.
- **Cross-check the price sum** against your own catalog. If the marketplace has a price-parity
  clause, summing both sides is a single number that proves every listing individually.
- Confirm each listing shows a pending/published status, not a draft.

## Example

```
eFinancialModels, 15 Excel models:
  1 modal open + 2 file_upload calls  -> 30 assets in the media library
  1 REST query                        -> 30 attachment ids + real filenames
  1 localStorage stage                -> 15 payloads + fill routine
  15 x (navigate + fill/submit)       -> 15 products PENDING
Verified: "Showing 1 to 15 of 15", price sum $1,685 == manifest $1,685
```

## Notes

- **A media modal left open silently overlays the form.** Screenshots and DOM reads then reflect
  the modal, not the form, and you will misdiagnose everything. Remove them before inspecting:
  `document.querySelectorAll('.media-modal, .media-modal-backdrop').forEach(m => m.remove())`.
- **Two open file inputs break element resolvers.** `find`-style semantic lookup cannot tell them
  apart and will hand you a button instead of the input. Remove the stale one first.
- **Read validation messages literally before believing them.** eFinancialModels emits
  "There are versions with empty version numbers" as a WARNING; the submit still succeeds. Chasing
  it as a blocker cost a lost draft. Conversely, check whether an apparent success dialog is
  hidden behind a modal you left open.
- **Featured images often have an aspect-ratio requirement** (eFM: 2:1, 1200x630). Square
  marketplace/shop imagery cannot be reused. Render purpose-built covers.
- **Price parity clauses bind your own storefront.** eFinancialModels forbids listing at a
  different price anywhere, including your own site, so a later discount on your site is a
  contract issue, not just a pricing decision.
- **Marketplaces gate even when their FAQ says otherwise.** Flevy's FAQ describes no approval
  step; the button reads "Submit for Approval". Assume review.
- Generate listing copy from measured facts (tab counts, formula counts, page counts read from the
  artifact) rather than existing marketing text — marketplaces with manual review are exactly where
  drifted claims get caught. See also `verify-modelstack-catalog-truthfulness`.

## References

- WordPress REST API media endpoint: https://developer.wordpress.org/rest-api/reference/media/
- See also: `web-action` (chooses API vs browser for a single web goal),
  `library-business-prospect-list` (sibling browser-automation gotchas),
  `ooxml-metadata-safe-edit` (preparing the files you are about to list).
