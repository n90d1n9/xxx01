// Robust FlashAd WebSocket client with auto-reconnect and JSON parsing
(function() {
    const WS_URL = (location.protocol === 'https:' ? 'wss://' : 'ws://') + location.host + '/ws/flash-ad';
    let ws;
    let reconnectTimeout = null;
    const RECONNECT_DELAY = 3000; // ms

    function connect() {
        ws = new WebSocket(WS_URL);

        ws.onopen = () => {
            console.log('FlashAd WebSocket connected');
        };

        ws.onmessage = (event) => {
            try {
                const flashAd = JSON.parse(event.data);
                console.log('Received FlashAd:', flashAd);
                // TODO: displayFlashAd(flashAd);
            } catch (e) {
                console.error('Invalid FlashAd JSON:', event.data);
            }
        };

        ws.onerror = (error) => {
            console.error('WebSocket error:', error);
        };

        ws.onclose = (event) => {
            console.warn('WebSocket closed:', event.reason);
            scheduleReconnect();
        };
    }

    function scheduleReconnect() {
        if (reconnectTimeout) return;
        reconnectTimeout = setTimeout(() => {
            reconnectTimeout = null;
            console.log('Reconnecting to FlashAd WebSocket...');
            connect();
        }, RECONNECT_DELAY);
    }

    // Start connection
    connect();

    // Expose for debugging
    window.flashAdWS = {
        get ws() { return ws; },
        reconnect: connect
    };
})();
