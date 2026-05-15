// Standard response envelope used by all responders.
class Response
{
    I32 StatusCode;
    U8 *StatusText;
    U8 *ContentType;
    U8 *Disposition;
    U8 *Body;
    I64 BodyLen;
};

// Write a Response to the client socket.
I64 WriteResponse(I32 fd, Response *r)
{
    U8 head[512];
    U8 *disp_line = "";
    U8 disp_buf[256];
    if (r->Disposition) {
        snprintf(disp_buf, sizeof(disp_buf), "Content-Disposition: %s\r\n", r->Disposition);
        disp_line = disp_buf;
    }
    I64 n = snprintf(head, sizeof(head),
        "HTTP/1.1 %d %s\r\n"
        "Content-Type: %s\r\n"
        "Content-Length: %d\r\n"
        "%s"
        "Connection: close\r\n\r\n",
        r->StatusCode, r->StatusText, r->ContentType, r->BodyLen, disp_line);
    send(fd, head, n, 0);
    return send(fd, r->Body, r->BodyLen, 0);
}

// 200 OK with a plain-text body.
U8 OkResponse(I32 fd, U8 *body)
{
    Response ok;
    MemSet(&ok, 0, sizeof(ok));
    ok.StatusCode = 200;
    ok.StatusText = "OK";
    ok.ContentType = "text/plain; charset=utf-8";
    ok.Body = MStrPrint("%s\n", body);
    ok.BodyLen = StrLen(ok.Body);
    WriteResponse(fd, &ok);
    Free(ok.Body);
    return 0;
}

// 404 Not Found.
U8 NotFoundResponse(I32 fd)
{
    Response not_found;
    MemSet(&not_found, 0, sizeof(not_found));
    not_found.StatusCode = 404;
    not_found.StatusText = "Not Found";
    not_found.ContentType = "text/plain; charset=utf-8";
    not_found.Body = "Not Found\n";
    not_found.BodyLen = StrLen(not_found.Body);
    WriteResponse(fd, &not_found);
    return 0;
}

// 400 Bad Request.
U8 BadRequestResponse(I32 fd)
{
    Response bad;
    MemSet(&bad, 0, sizeof(bad));
    bad.StatusCode = 400;
    bad.StatusText = "Bad Request";
    bad.ContentType = "text/plain; charset=utf-8";
    bad.Body = "Bad Request\n";
    bad.BodyLen = StrLen(bad.Body);
    WriteResponse(fd, &bad);
    return 0;
}

// 200 OK with file contents at `path`. 404s if the file is missing.
U8 FileResponse(I32 fd, U8 *path, U8 *content_type)
{
    I64 size;
    U8 *contents = ReadAll(path, &size);
    if (!contents) {
        LogWarn("file not found: %s", path);
        NotFoundResponse(fd);
        return 1;
    }

    Response file;
    MemSet(&file, 0, sizeof(file));
    file.StatusCode = 200;
    file.StatusText = "OK";
    file.ContentType = content_type;
    file.Body = contents;
    file.BodyLen = size;
    WriteResponse(fd, &file);

    Free(contents);
    return 0;
}

// Try to serve `path` with status 200. Returns 1 on success, 0 if the file
// doesn't exist (without writing anything to fd, so the caller can try a
// different lookup).
I64 TryServeFile(I32 fd, U8 *path, U8 *content_type)
{
    I64 size;
    U8 *contents = ReadAll(path, &size);
    if (!contents) return 0;

    Response r;
    MemSet(&r, 0, sizeof(r));
    r.StatusCode = 200;
    r.StatusText = "OK";
    r.ContentType = content_type;
    r.Body = contents;
    r.BodyLen = size;
    WriteResponse(fd, &r);
    Free(contents);
    return 1;
}

// 200 OK with an inline HTML string.
U8 HtmlResponse(I32 fd, U8 *body)
{
    Response html;
    MemSet(&html, 0, sizeof(html));
    html.StatusCode = 200;
    html.StatusText = "OK";
    html.ContentType = "text/html; charset=utf-8";
    html.Body = body;
    html.BodyLen = StrLen(html.Body);
    WriteResponse(fd, &html);
    return 0;
}

// 200 OK with file contents served as a download.
U8 FileDownloadResponse(I32 fd, U8 *path, U8 *content_type, U8 *filename)
{
    I64 size;
    U8 *contents = ReadAll(path, &size);
    if (!contents) { NotFoundResponse(fd); return 1; }

    U8 disp[256];
    snprintf(disp, sizeof(disp), "attachment; filename=\"%s\"", filename);

    Response download;
    MemSet(&download, 0, sizeof(download));
    download.StatusCode = 200;
    download.StatusText = "OK";
    download.ContentType = content_type;
    download.Disposition = disp;
    download.Body = contents;
    download.BodyLen = size;
    WriteResponse(fd, &download);
    Free(contents);
    return 0;
}
