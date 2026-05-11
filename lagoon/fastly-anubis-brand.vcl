## Fastly VCL: amazee.io-branded Anubis splash page
##
## Anubis renders its challenge/error pages with asset paths under
## `/.within.website/x/...` that are served by the Anubis container itself.
## We can't override these from the application side (Anubis serves them
## before any request reaches nginx), but Fastly sits in front of Anubis,
## so we rewrite the four asset URLs at the edge to point at our own
## branded files under `/anubis-brand/*` served by nginx.
##
## The matching `/anubis-brand/*` ALLOW rule lives in lagoon/botPolicies.yaml
## so these requests pass through Anubis without being challenged.
##
## Where this goes: paste the body of `vcl_recv_anubis_brand` (or include
## this whole file) into the project's Fastly service via the amazee.io
## support team or the Lagoon Fastly integration. Anchor it inside the
## existing `vcl_recv` subroutine, before any backend selection logic.

# Anubis's bundled CSS — rewrite to our amazee.io-branded stylesheet.
if (req.url.path == "/.within.website/x/xess/xess.min.css") {
  set req.url = "/anubis-brand/xess.min.css";
}

# Three mascot images shown during challenge / success / failure.
if (req.url.path == "/.within.website/x/cmd/anubis/static/img/pensive.webp") {
  set req.url = "/anubis-brand/pensive.webp";
}
if (req.url.path == "/.within.website/x/cmd/anubis/static/img/happy.webp") {
  set req.url = "/anubis-brand/happy.webp";
}
if (req.url.path == "/.within.website/x/cmd/anubis/static/img/reject.webp") {
  set req.url = "/anubis-brand/reject.webp";
}

## Production wiring (paste inside the project's main vcl_recv):
#
# sub vcl_recv {
#   #FASTLY recv
#   call vcl_recv_anubis_brand;
#   ...existing logic...
# }
#
## Cache hint: the rewritten responses are plain static files served by
## nginx with normal cache headers, so no extra Fastly cache logic is needed.
## If you want to force long-lived caching on the branded assets regardless
## of origin headers, add the following to vcl_fetch:
#
# sub vcl_fetch {
#   if (req.url.path ~ "^/anubis-brand/") {
#     set beresp.cacheable = true;
#     set beresp.ttl = 7d;
#     set beresp.http.Cache-Control = "public, max-age=604800, immutable";
#     unset beresp.http.Set-Cookie;
#   }
# }
