// Parse the request path out of an HTTP request line.
// Writes the path (without query string) into `out`.
I64 ParsePath(U8 *req, U8 *out, I64 out_cap)
{
    U8 *p = req;
    while (*p && *p != ' ') p++;
    if (!*p) return -1;
    p++;
    U8 *start = p;
    while (*p && *p != ' ' && *p != '?' && *p != '\r' && *p != '\n') p++;
    I64 len = p - start;
    if (len >= out_cap) len = out_cap - 1;
    MemCpy(out, start, len);
    out[len] = '\0';
    return len;
}

// True iff path is a safe request path:
//   - starts with '/'
//   - chars are [A-Za-z0-9._/-] only
//   - no empty segment ("//"), no segment beginning with '.' (blocks "..", ".env", ".git", etc.)
// Trailing slash is allowed; callers should normalize before this if they want a canonical form.
I64 IsSafeRequestPath(U8 *p)
{
    if (*p != '/') return 0;
    while (*p) {
        U8 c = *p;
        if (c == '/') {
            U8 next = p[1];
            if (next == '\0') { p++; break; }
            if (next == '/' || next == '.') return 0;
            p++;
        } else if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')
                || (c >= '0' && c <= '9') || c == '-' || c == '_' || c == '.') {
            p++;
        } else {
            return 0;
        }
    }
    return 1;
}

// Copy `in` to `out` with any single trailing '/' stripped (except the root "/").
I64 NormalizePath(U8 *in, U8 *out, I64 out_cap)
{
    I64 len = StrLen(in);
    if (len > 1 && in[len - 1] == '/') len--;
    if (len >= out_cap) len = out_cap - 1;
    MemCpy(out, in, len);
    out[len] = '\0';
    return len;
}

// True if `path` starts with `prefix`.
I64 StartsWith(U8 *path, U8 *prefix)
{
    while (*prefix) if (*path++ != *prefix++) return 0;
    return 1;
}

// True if `path` equals `route` byte-for-byte.
I64 MatchRoute(U8 *path, U8 *route) { return !StrCmp(path, route); }

// Read entire file into a fresh buffer. Caller frees. Returns NULL on error.
U8 *ReadAll(U8 *path, I64 *out_size)
{
    I32 fd = open(path, 0, 0);
    if (fd < 0) return NULL;

    I64 len = lseek(fd, 0, 2);
    lseek(fd, 0, 0);

    U8 *buf = MAlloc(len + 1);
    I64 total = 0;
    I64 n;
    while ((n = read(fd, buf + total, len - total)) > 0) total += n;
    close(fd);

    if (total != len) { Free(buf); return NULL; }
    buf[len] = '\0';
    if (out_size) *out_size = len;
    return buf;
}
