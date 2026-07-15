---
name: twilio-webhook-signature-validation
description: |
  Fix and debug Twilio X-Twilio-Signature validation failures. Use when:
  (1) callers hear "an application error has occurred" on a Twilio number,
  (2) Twilio Debugger shows error 11200 "Got HTTP 403 response" from your own
  webhook, (3) hand-rolled signature validation rejects REAL Twilio requests
  while correctly rejecting unsigned ones, (4) webhooks behind a non-standard
  port (Tailscale Funnel, ngrok, custom proxy) fail validation. Root cause:
  Twilio may sign the URL WITHOUT the non-standard port. Includes the
  capture-and-brute-force recipe for any signed-webhook mismatch.
author: Claude Code
version: 1.0.0
date: 2026-06-12
---

# Twilio Webhook Signature Validation

## Problem

Hand-rolled X-Twilio-Signature validation that HMACs `https://host:PORT/path`
rejects every REAL Twilio request when the webhook lives on a non-standard
port, because Twilio may compute the signature over the URL WITHOUT the port
(`https://host/path`). The caller-facing symptom ("an application error has
occurred") and the server-side symptom (your own 403) both look like
someone ELSE's failure.

The trap that ships this bug: validation gets verified only on its REJECT
path (curl an unsigned request, see 403, declare it armed). The accept path
for a genuinely signed request is never exercised until a real call fails in
production.

## Context / Trigger Conditions

- Caller hears "an application error has occurred" on a Twilio number.
- Twilio Monitor/Debugger alert: `11200` with `Got HTTP 403 response to
  https://...` pointing at YOUR webhook.
- Your webhook log shows "bad signature" rejections for requests whose
  params look like real Twilio traffic (CallSid, AccountSid, StirStatus...).
- Webhook URL has a non-standard port (`:10000`, `:8443`...) via a tunnel or
  reverse proxy.

## Solution

1. **Check Twilio's view first** (seconds, no guessing):
   `GET https://monitor.twilio.com/v1/Alerts?PageSize=8` with account
   SID:token basic auth. Error 11200 + the HTTP status tells you whether
   Twilio got your 403 (signature bug) vs 502 (ingress dead).
2. **Validate against BOTH URL forms.** Compute the expected HMAC for each
   candidate and timingSafeEqual against the received header:

   ```ts
   const u = new URL(configuredWebhookUrl);
   const candidates = new Set([
     configuredWebhookUrl,                                   // with port
     `${u.protocol}//${u.hostname}${u.pathname}${u.search}`, // port stripped
   ]);
   const suffix = [...params.keys()].sort().map(k => k + params.get(k)).join("");
   // accept if ANY candidate's HMAC-SHA1(authToken) base64 matches the header
   ```

   (twilio-node's own docs advise checking both forms.)
3. **Confirm the auth token is the PRIMARY.** API basic-auth accepts
   secondary tokens, but signatures are computed with the primary. The
   Account resource (`GET /2010-04-01/Accounts/{sid}.json`) returns
   `auth_token` — compare directly.
4. **If still mismatched, capture a real signed request and brute-force the
   construction offline:**
   - Originate a call via the REST API so you don't need a human caller:
     `POST /2010-04-01/Accounts/{sid}/Calls.json` with `Url=` your webhook
     and `To=` a number that answers. When the call connects, Twilio fetches
     your Url with a REAL signature.
   - Temporarily log the raw body + received `X-Twilio-Signature` on
     mismatch.
   - Offline, HMAC candidate data strings (URL with/without port, trailing
     slash, http/https, raw vs decoded params, `+`-as-space vs literal)
     until one matches the captured header. One match = root cause.

## Verification

A REAL signed request must pass end-to-end (for voice: TwiML returned →
ConversationRelay/next webhook actually proceeds), not just "unsigned curl
gets 403". Drive one genuine request through the gate before declaring any
signature validation armed.

## Example

agor-agents phone bridge (2026-06-12): webhook
`https://host.ts.net:10000/voice` behind Tailscale Funnel. Unsigned-reject
verified; first real PSTN call after arming → 403 → caller heard
"application error". Brute-force matched `https://host.ts.net/voice` +
decoded params with `+`-as-space. Fix: candidate-set validation as above;
proven with an API-originated call streaming a full turn.

## Notes

- General principle (beyond Twilio): a security gate verified only on its
  reject path is unverified. Rejecting garbage proves nothing about
  accepting the real thing.
- Don't log full raw bodies permanently — they contain caller numbers. Trim
  the diagnostic once root-caused.
- `crypto.timingSafeEqual` throws on length mismatch; wrap per candidate.

## References

- https://www.twilio.com/docs/usage/security#validating-requests
- twilio-node `validateRequest` docs (advises validating with and without port)
