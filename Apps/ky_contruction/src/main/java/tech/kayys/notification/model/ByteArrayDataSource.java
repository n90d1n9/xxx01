package tech.kayys.notification.model;

public  class ByteArrayDataSource implements DataSource {
        private final byte[] data;
        private final String contentType;

        public ByteArrayDataSource(byte[] data, String contentType) {
            this.data = data;
            this.contentType = contentType;
        }

        @Override
        public InputStream getInputStream() { return new ByteArrayInputStream(data); }

        @Override
        public OutputStream getOutputStream() {
            throw new UnsupportedOperationException("Read-only data source");
        }

        @Override
        public String getContentType() { return contentType; }

        @Override
        public String getName() { return "attachment"; }
    }