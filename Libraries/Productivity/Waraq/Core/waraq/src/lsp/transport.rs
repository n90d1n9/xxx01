// src/lsp/transport.rs
//
// LSP transport: framing over stdin/stdout.
//
// LSP uses HTTP-like headers:
//   Content-Length: <bytes>\r\n
//   \r\n
//   <JSON body>

use std::io::BufRead;

/// Encode a JSON-RPC message for LSP transport.
pub fn encode_message(body: &str) -> Vec<u8> {
    let header = format!("Content-Length: {}\r\n\r\n", body.len());
    let mut out = header.into_bytes();
    out.extend_from_slice(body.as_bytes());
    out
}

/// Read one LSP message from a buffered reader.
pub fn read_message<R: BufRead>(reader: &mut R) -> anyhow::Result<String> {
    let mut content_length: Option<usize> = None;

    // Read headers
    loop {
        let mut header_line = String::new();
        reader.read_line(&mut header_line)?;
        let header_line = header_line.trim();
        if header_line.is_empty() {
            break;
        }
        if let Some(len) = header_line.strip_prefix("Content-Length: ") {
            content_length = Some(len.parse()?);
        }
    }

    let len = content_length.ok_or_else(|| anyhow::anyhow!("Missing Content-Length"))?;

    // Read body
    let mut body = vec![0u8; len];
    reader.read_exact(&mut body)?;
    Ok(String::from_utf8(body)?)
}

/// Decode one or more complete LSP-framed messages from a byte buffer.
pub fn decode_messages(buffer: &[u8]) -> Vec<String> {
    let mut messages = Vec::new();
    let mut offset = 0;

    while offset < buffer.len() {
        let Some(header_end_rel) = buffer[offset..]
            .windows(4)
            .position(|window| window == b"\r\n\r\n")
        else {
            break;
        };

        let header_end = offset + header_end_rel;
        let header = match std::str::from_utf8(&buffer[offset..header_end]) {
            Ok(header) => header,
            Err(_) => break,
        };

        let content_length = header.lines().find_map(|line| {
            line.strip_prefix("Content-Length: ")
                .and_then(|value| value.trim().parse::<usize>().ok())
        });

        let Some(content_length) = content_length else {
            break;
        };

        let body_start = header_end + 4;
        let body_end = body_start + content_length;
        if body_end > buffer.len() {
            break;
        }

        if let Ok(body) = String::from_utf8(buffer[body_start..body_end].to_vec()) {
            messages.push(body);
        }

        offset = body_end;
    }

    messages
}

/// Decode the first complete LSP-framed message from a byte buffer.
pub fn decode_message(buffer: &[u8]) -> anyhow::Result<String> {
    decode_messages(buffer)
        .into_iter()
        .next()
        .ok_or_else(|| anyhow::anyhow!("No complete LSP message"))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Cursor;

    #[test]
    fn test_encode_message() {
        let body = r#"{"jsonrpc":"2.0","id":1,"method":"initialize"}"#;
        let encoded = encode_message(body);
        let s = String::from_utf8(encoded).unwrap();
        assert!(s.starts_with("Content-Length:"));
        assert!(s.contains(&format!("{}", body.len())));
        assert!(s.contains("\r\n\r\n"));
        assert!(s.ends_with(body));
    }

    #[test]
    fn test_round_trip() {
        let body = r#"{"jsonrpc":"2.0","result":null,"id":42}"#;
        let encoded = encode_message(body);
        let mut cursor = Cursor::new(encoded);
        use std::io::BufReader;
        let mut reader = BufReader::new(&mut cursor);
        let decoded = read_message(&mut reader).unwrap();
        assert_eq!(decoded, body);
    }

    #[test]
    fn test_encode_unicode_body() {
        let body = r#"{"text":"こんにちは世界"}"#;
        let encoded = encode_message(body);
        // Content-Length should be byte length, not char length
        let s = String::from_utf8(encoded.clone()).unwrap();
        let len_str = s
            .split("Content-Length: ")
            .nth(1)
            .unwrap()
            .split("\r\n")
            .next()
            .unwrap();
        let reported_len: usize = len_str.parse().unwrap();
        assert_eq!(reported_len, body.len());
    }
}
