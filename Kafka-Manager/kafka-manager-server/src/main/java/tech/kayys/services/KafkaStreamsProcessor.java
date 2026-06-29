package tech.kayys.services;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.Produced;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.inject.Produces;

import java.util.Locale;

@ApplicationScoped
public class KafkaStreamsProcessor {

    @ConfigProperty(name = "mp.messaging.incoming.messages-in.topic")
    String inputTopic;

    @ConfigProperty(name = "mp.messaging.outgoing.messages-out.topic")
    String outputTopic;

    @Produces
    public Topology buildTopology() {
        StreamsBuilder builder = new StreamsBuilder();
        
        KStream<String, String> stream = builder.stream(
            inputTopic, 
            Consumed.with(Serdes.String(), Serdes.String())
        );

        // Simple processing: uppercase all messages
        stream.mapValues(value -> value.toUpperCase(Locale.ROOT))
              .to(outputTopic, Produced.with(Serdes.String(), Serdes.String()));

        return builder.build();
    }
}
