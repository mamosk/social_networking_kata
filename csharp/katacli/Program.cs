using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using McMaster.Extensions.Hosting.CommandLine;
using McMaster.Extensions.CommandLineUtils;
using System;
using System.IO;
using System.Threading.Tasks;
using System.Transactions;

namespace katacli
{
    class Program
    {
        private static async Task Main(string[] args) => await CreateHostBuilder(args).Build().RunCommandLineApplicationAsync<IKataCli>();
        //var Configuration = new ConfigurationBuilder()
        //    .
        //    .SetBasePath(Directory.GetCurrentDirectory())
        //    .AddJsonFile(AppDomain.CurrentDomain.BaseDirectory + "\\appsettings.json", optional: true, reloadOnChange: true)
        //    .AddEnvironmentVariables()
        //    .Build();

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureHostConfiguration(host =>
                    host.SetBasePath(Directory.GetCurrentDirectory())
                        .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                        .AddEnvironmentVariables(prefix: "CLI_")
                )
                .ConfigureServices((context, services) =>
                    services.AddSingleton<IKataCli, KataCli>()
                        .AddHttpClient()
                )
            ;
    }
}
