extern "c" I32 fflush(U0 *stream);
extern "c" I64 time(I64 *t);
extern "c" U0 *localtime(I64 *t);
extern "c" I64 strftime(U8 *s, I64 max, U8 *fmt, U0 *tm);

#define ANSI_RESET "\033[0m"
#define ANSI_GRAY "\033[90m"
#define ANSI_GREEN "\033[32m"
#define ANSI_YELLOW "\033[33m"
#define ANSI_RED "\033[31m"
#define ANSI_CYAN "\033[36m"

U0 _LogAt(U8 *level, U8 *color, U8 *fmt, I64 argc, I64 *argv)
{
    I64 t = time(NULL);
    U8 ts[32];
    strftime(ts, sizeof(ts), "%Y-%m-%d %H:%M:%S", localtime(&t));

    U8 *msg = StrPrintJoin(NULL, fmt, argc, argv);
    "%s%s%s %s[%s]%s %s\n",
        ANSI_GRAY, ts, ANSI_RESET,
        color, level, ANSI_RESET,
        msg;
    fflush(NULL);
    Free(msg);
}

U0 LogInfo(U8 *fmt, ...)  { _LogAt("INFO",  ANSI_GREEN,  fmt, argc, argv); }
U0 LogWarn(U8 *fmt, ...)  { _LogAt("WARN",  ANSI_YELLOW, fmt, argc, argv); }
U0 LogError(U8 *fmt, ...) { _LogAt("ERROR", ANSI_RED,    fmt, argc, argv); }
U0 LogDebug(U8 *fmt, ...) { _LogAt("DEBUG", ANSI_CYAN,   fmt, argc, argv); }
