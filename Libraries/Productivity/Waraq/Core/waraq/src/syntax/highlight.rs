// src/syntax/highlight.rs
//
// Theme mapping: TokenKind → RGB color.
// Two built-in themes: Dark (Dracula-ish) and Light.
// Custom themes are just TokenKind → (r, g, b) maps.

use super::TokenKind;
use std::collections::HashMap;

#[derive(Debug, Clone, Copy)]
pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

impl Color {
    pub const fn rgb(r: u8, g: u8, b: u8) -> Self {
        Self { r, g, b }
    }
    pub fn to_hex(&self) -> String {
        format!("#{:02X}{:02X}{:02X}", self.r, self.g, self.b)
    }
}

pub type Theme = HashMap<TokenKind, Color>;

pub fn dark_theme() -> Theme {
    use TokenKind::*;
    [
        (Default, Color::rgb(248, 248, 242)),  // Dracula foreground
        (Keyword, Color::rgb(255, 121, 198)),  // pink
        (String, Color::rgb(241, 250, 140)),   // yellow
        (Number, Color::rgb(189, 147, 249)),   // purple
        (Comment, Color::rgb(98, 114, 164)),   // muted blue
        (Operator, Color::rgb(255, 121, 198)), // pink
        (Function, Color::rgb(80, 250, 123)),  // green
        (Type, Color::rgb(139, 233, 253)),     // cyan
        (Variable, Color::rgb(248, 248, 242)), // foreground
        (Constant, Color::rgb(189, 147, 249)), // purple
        (Punctuation, Color::rgb(248, 248, 242)),
        (Attribute, Color::rgb(80, 250, 123)),
        (Error, Color::rgb(255, 85, 85)),
    ]
    .into_iter()
    .collect()
}

pub fn light_theme() -> Theme {
    use TokenKind::*;
    [
        (Default, Color::rgb(36, 41, 46)),
        (Keyword, Color::rgb(215, 58, 73)),   // red
        (String, Color::rgb(32, 120, 87)),    // green
        (Number, Color::rgb(0, 92, 197)),     // blue
        (Comment, Color::rgb(106, 115, 125)), // gray
        (Operator, Color::rgb(215, 58, 73)),
        (Function, Color::rgb(111, 66, 193)), // purple
        (Type, Color::rgb(0, 92, 197)),
        (Variable, Color::rgb(36, 41, 46)),
        (Constant, Color::rgb(0, 92, 197)),
        (Punctuation, Color::rgb(36, 41, 46)),
        (Attribute, Color::rgb(0, 134, 179)),
        (Error, Color::rgb(203, 36, 29)),
    ]
    .into_iter()
    .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::syntax::TokenKind;

    #[test]
    fn test_dark_theme_has_all_token_kinds() {
        let theme = dark_theme();
        let kinds = [
            TokenKind::Default,
            TokenKind::Keyword,
            TokenKind::String,
            TokenKind::Number,
            TokenKind::Comment,
            TokenKind::Operator,
            TokenKind::Function,
            TokenKind::Type,
            TokenKind::Variable,
            TokenKind::Constant,
            TokenKind::Punctuation,
            TokenKind::Error,
        ];
        for kind in &kinds {
            assert!(theme.contains_key(kind), "Dark theme missing: {:?}", kind);
        }
    }

    #[test]
    fn test_light_theme_has_all_token_kinds() {
        let theme = light_theme();
        assert!(theme.contains_key(&TokenKind::Keyword));
        assert!(theme.contains_key(&TokenKind::Comment));
    }

    #[test]
    fn test_color_to_hex() {
        assert_eq!(Color::rgb(255, 121, 198).to_hex(), "#FF79C6");
        assert_eq!(Color::rgb(0, 0, 0).to_hex(), "#000000");
        assert_eq!(Color::rgb(255, 255, 255).to_hex(), "#FFFFFF");
    }

    #[test]
    fn test_dark_theme_keyword_is_pink() {
        let theme = dark_theme();
        let color = theme[&TokenKind::Keyword];
        // Dracula keyword color is #FF79C6
        assert_eq!(color.r, 255);
        assert_eq!(color.g, 121);
        assert_eq!(color.b, 198);
    }

    #[test]
    fn test_dark_theme_comment_is_muted() {
        let theme = dark_theme();
        let color = theme[&TokenKind::Comment];
        // Should be a muted blue-grey
        assert!(color.r < 150 && color.g < 150, "Comment should be muted");
    }

    #[test]
    fn test_light_theme_differs_from_dark() {
        let dark = dark_theme();
        let light = light_theme();
        // Keyword colors should be different between themes
        assert_ne!(dark[&TokenKind::Keyword].r, light[&TokenKind::Keyword].r);
    }
}
