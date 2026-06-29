package tech.kayys.services;

import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import org.eclipse.microprofile.reactive.messaging.Incoming;
import org.jboss.logging.Logger;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

@ApplicationScoped
public class KafkaMessageService {

    private static final Logger LOG = Logger.getLogger(KafkaMessageService.class);

    @Inject
    @Channel("messages-out")
    Emitter<String> messageEmitter;

    private final ConcurrentMap<String, String> receivedMessages = new ConcurrentHashMap<>();

    public void sendMessage(String message) {
        messageEmitter.send(message);
    }

    @Incoming("messages-in")
    public void receiveMessage(String message) {
        LOG.infof("Received message: %s", message);
        receivedMessages.put(UUID.randomUUID().toString(), message);
    }

    public ConcurrentMap<String, String> getReceivedMessages() {
        return new ConcurrentHashMap<>(receivedMessages);
    }
}