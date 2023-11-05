using Confluent.Kafka;

namespace subscriber;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly ConsumerConfig _consumerConfig;

    public Worker(ILogger<Worker> logger, IConfiguration configuration)
    {
        _logger = logger;

        var kafkaHost = configuration["KafkaHost"];
        if (string.IsNullOrEmpty(kafkaHost))
        {
            throw new InvalidOperationException("Cannot find KafkaHost configuration setting.");
        }
        _consumerConfig = new ConsumerConfig
        {
            BootstrapServers = kafkaHost,
            GroupId = "challenge2-group",
            AutoOffsetReset = AutoOffsetReset.Earliest
        };
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var consumer = new ConsumerBuilder<Ignore, string>(_consumerConfig)
            .SetErrorHandler((consumer1, error) => _logger.LogError(error.Reason))
            .Build();
        consumer.Subscribe("challenge2-topic");

        while (!stoppingToken.IsCancellationRequested)
        {
            var consumeResult = consumer.Consume(stoppingToken);
            consumer.Commit(consumeResult);
            _logger.LogInformation(@"Event number {offset} received with message: {message}", consumeResult.Offset, consumeResult.Message.Value);
        }

        consumer.Close();
    }
}
