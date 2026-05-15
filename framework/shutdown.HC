extern "c" U0 signal(I32 signum, U0 (*handler)(I32));
extern "c" U0 exit(I32 code);

#define SIGINT 2
#define SIGTERM 15

U0 OnShutdown(I32 sig)
{
    LogInfo("shutting down (signal %d)", sig);
    exit(0);
}

U0 InitShutdownHandler()
{
    signal(SIGINT, &OnShutdown);
    signal(SIGTERM, &OnShutdown);
}
