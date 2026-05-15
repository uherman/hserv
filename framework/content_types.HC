// Map a path's extension to a MIME content-type string.
// Returns "application/octet-stream" if the extension is unknown or missing.
U8 *ContentTypeFor(U8 *path)
{
    I64 len = StrLen(path);
    I64 i = len - 1;
    while (i >= 0 && path[i] != '.' && path[i] != '/') i--;
    if (i < 0 || path[i] != '.') return "application/octet-stream";

    U8 *ext = path + i + 1;

    if (!StrCmp(ext, "html") || !StrCmp(ext, "htm"))   return "text/html; charset=utf-8";
    if (!StrCmp(ext, "css"))                            return "text/css; charset=utf-8";
    if (!StrCmp(ext, "js") || !StrCmp(ext, "mjs"))      return "application/javascript; charset=utf-8";
    if (!StrCmp(ext, "json"))                           return "application/json; charset=utf-8";
    if (!StrCmp(ext, "txt") || !StrCmp(ext, "md"))      return "text/plain; charset=utf-8";
    if (!StrCmp(ext, "xml"))                            return "application/xml; charset=utf-8";
    if (!StrCmp(ext, "svg"))                            return "image/svg+xml";
    if (!StrCmp(ext, "png"))                            return "image/png";
    if (!StrCmp(ext, "jpg") || !StrCmp(ext, "jpeg"))    return "image/jpeg";
    if (!StrCmp(ext, "gif"))                            return "image/gif";
    if (!StrCmp(ext, "webp"))                           return "image/webp";
    if (!StrCmp(ext, "ico"))                            return "image/x-icon";
    if (!StrCmp(ext, "woff"))                           return "font/woff";
    if (!StrCmp(ext, "woff2"))                          return "font/woff2";
    if (!StrCmp(ext, "ttf"))                            return "font/ttf";
    if (!StrCmp(ext, "otf"))                            return "font/otf";
    if (!StrCmp(ext, "pdf"))                            return "application/pdf";
    if (!StrCmp(ext, "wasm"))                           return "application/wasm";

    return "application/octet-stream";
}
