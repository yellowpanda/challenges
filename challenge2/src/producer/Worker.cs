using Confluent.Kafka;

namespace producer;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly ProducerConfig _producerConfig;

    public Worker(ILogger<Worker> logger, IConfiguration configuration)
    {
        _logger = logger;

        var kafkaHost = configuration["KafkaHost"];
        if (string.IsNullOrEmpty(kafkaHost))
        {
            throw new InvalidOperationException("Cannot find KafkaHost configuration setting.");
        }

        _producerConfig = new ProducerConfig
        {
            BootstrapServers = kafkaHost,
        };
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation(@"Produce events to {kafkaHost}", _producerConfig.BootstrapServers);
        while (!stoppingToken.IsCancellationRequested)
        {
            using var producer = new ProducerBuilder<Null, string>(_producerConfig)
                .SetErrorHandler((producer, error) =>
                {
                    _logger.LogError("Tried to produced events to {kafkaHost} and got error: {error}", _producerConfig.BootstrapServers, error.Reason);
                })
                .Build();

            var result = await producer.ProduceAsync("challenge2-topic", new Message<Null, string> { Value = "Hello!" }, stoppingToken);
            _logger.LogInformation(@"Worker running at {time} and published event number {resultOffset}.", DateTimeOffset.Now, result.Offset);

            await Task.Delay(1000, stoppingToken);
        }
    }
}
