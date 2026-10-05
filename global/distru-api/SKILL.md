---
name: distru-api
description: Build, review, or debug an integration with the Distru public API — the ERP for the cannabis supply chain (orders, invoices, inventory, purchases, manufacturing, Metrc/BioTrack compliance). Use when writing code that calls app.distru.com/public/v1, generating a client from Distru's OpenAPI spec, or diagnosing Distru API errors, pagination, webhooks, or compliance sync behavior.
---

# Distru API

REST API at `https://app.distru.com/public/v1/`. JSON in, JSON out. API access must be enabled for the account by a Distru representative; a sandbox environment is available on request.

For anything not covered here, fetch the references — do not guess:

- Full documentation (one Markdown file): https://apidocs.distru.dev/llms-full.txt
- OpenAPI 3.0 spec (exact schemas): https://apidocs.distru.dev/openapi.json

## Every request

- Headers: `Authorization: Bearer <API_TOKEN>`, `Content-Type: application/json`, `Accept: application/json`.
- Tokens are created by an admin in the Distru app (Settings → Integrations → Distru API) and carry that admin's permissions. Keep them server-side only.
- Treat every id as an opaque string. Never parse, construct, or guess ids.

## Reading data

- Request a list endpoint with no page parameter to get the first page, then paginate by following the `next_page` URL in each paginated response — pass it back exactly as given — until it is null. Never build a page selector yourself and never assume a page size; the server may change it at any time.
- Array filters repeat a bracketed key: `?ids[]=a&ids[]=b` (max 200 values). A bare `?ids=a` is a 400.
- Datetime filters are inclusive comma ranges: `?updated_datetime=<min>,<max>`. Omit one side for open-ended (`?updated_datetime=2025-05-04T00:00:00.000000Z,` means on-or-after).
- Webhooks (create/edit/delete events pushed to your endpoint) exist only for the main entity types — orders, invoices, purchases, and the like; check the webhooks docs for the current list.
- To keep a near-real-time local copy of Distru records, poll each list endpoint periodically with an `updated_datetime` lower bound set to your last successful sync, walk every page, and upsert the results into your local store. This works for every entity type.

## Writing data

- Writes are upserts: one `POST` serves create and update. `id` absent → create, `id` present → update. Same URL, same request shape.
- Updates are sparse: an omitted field is left unchanged; a field sent as `null` is cleared (required fields reject `null` with a 400). Creates are not sparse — send every required field.
- Nested collections (`items`, `charges`) are optional: omit the collection entirely to leave existing rows untouched. But if you DO send it, you replace the whole set: an existing row whose `id` you omit is DELETED, an entry with just `{"id": "..."}` keeps that row unchanged, an entry with an existing `id` plus fields patches that row, and an entry without an `id` is added. Each endpoint's docs spell out its exact collection semantics — read them before writing.
- Enums are SCREAMING_CASE in requests and responses (`"COMPLETED"`, not `"completed"`), with a few exceptions — check the OpenAPI spec for each field's exact values rather than converting case blindly.
- Some writes sync to 3rd-party systems (Metrc/QuickBooks Online/BioTrack) asynchronously: a 200 means the change was accepted in Distru, not that it synced to the 3rd party system yet. Poll the corresponding GET endpoint to observe the synced result.

## Errors

Every error, on every endpoint, has one shape:

```json
{
  "errors": [
    {"message": "Human-readable reason", "pointer": ["items", 0, "quantity"]}
  ]
}
```

`pointer` is the path to the offending request field; `["base"]` means the whole request. Write one error parser and reuse it everywhere.

Status codes — the complete set:

| Code    | Meaning                                                            | Handle by                                          |
| ------- | ------------------------------------------------------------------ | -------------------------------------------------- |
| 200/201 | success                                                            | —                                                  |
| 400     | bad input (validation, malformed filter, business rule)            | fix the field at `pointer`; do not retry unchanged |
| 401     | missing/invalid token                                              | check the `Authorization` header                   |
| 403     | token lacks the required permission                                | grant the permission in Distru; not a retry case   |
| 404     | no such record for this account (unknown id, or another account's) | treat as not-found, not as a transient error       |
| 429     | rate limited                                                       | wait `Retry-After` seconds, then retry             |

The API never returns 422 — if your client special-cases it, remove that.

## Rate limits

Only PDF endpoints (paths ending in `/pdf`) are rate limited: 20/minute and 1,000/day per account, aggregated across all PDF endpoints. Only successful downloads count. A 429 carries a `Retry-After` header — honor it exactly; the window is sliding, so fixed-schedule retries waste quota.

## Go-live checklist

Before pointing the integration at production:

- Whoever owns the integration is subscribed to the [API email list](https://share.hsforms.com/1ui8lKXQ2RAaytYEyEphCiQ2usrt) — the only channel for breaking-change announcements.
- The integration was tested against the sandbox environment, not production data.
- One shared error parser handles the `{ "errors": [ { "message", "pointer" } ] }` envelope on every endpoint.
- Every list read follows `next_page` until it is null — no page-size or page-count assumptions anywhere.

## Staying current

Breaking changes are announced ONLY via the API email list (see the go-live checklist). New endpoints and fields appear in the [changelog](https://apidocs.distru.dev/#changelog), newest first.
