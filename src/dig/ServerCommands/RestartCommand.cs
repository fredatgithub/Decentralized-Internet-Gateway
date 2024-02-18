namespace dig;

using System.IO;

internal sealed class RestartCommand()
{
    [Option("s", "settings", ArgumentHelpName = "FILE_PATH", Description = "Full path to a settings file.")]
    public string? Settings { get; init; }

    [CommandTarget]
    public async Task<int> Execute(ILogger<StartCommand> logger)
    {
        await Task.CompletedTask;

        if (Settings is not null && !File.Exists(Settings))
        {
            logger.LogError("Settings file not found {path}.", Settings);
            return -1;
        }

        if (ServerProcess.GetIsRunning())
        {
            Console.WriteLine($"Stopping server...");
            ServerProcess.Stop();
            Console.WriteLine($"Server stopped.");
        }

        try
        {
            logger.LogInformation("Starting server...");
            ServerProcess.Start(Settings);
            logger.LogInformation("Server started.");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to start server.");
            return -1;
        }

        return 0;
    }
}
