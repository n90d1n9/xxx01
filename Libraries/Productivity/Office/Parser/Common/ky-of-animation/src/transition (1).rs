use roxmltree::Node;
use crate::models::transition::*;

/// Parse a `<p:transition>` element.
pub fn parse_transition(node: Node) -> SlideTransition {
    let duration_ms = node.attribute("dur")
        .and_then(|v| v.parse().ok());
    let advance_on_click = node.attribute("advClick")
        .map(|v| v != "0" && v != "false")
        .unwrap_or(true);
    let advance_after_ms = node.attribute("advTm")
        .and_then(|v| v.parse().ok());

    let mut effect = TransitionEffect::None;
    let mut sound = None;

    for child in node.children() {
        let tag = child.tag_name().name();
        match tag {
            "sndAc" => {
                sound = parse_transition_sound(child);
            }
            // Fade family
            "fade" => {
                let through_black = child.attribute("thruBlk")
                    .map(|v| v == "1" || v == "true")
                    .unwrap_or(false);
                effect = if through_black { TransitionEffect::CutThroughBlack } else { TransitionEffect::Fade };
            }
            "cut" => {
                effect = TransitionEffect::Cut;
            }
            // Wipe/Push family
            "blinds" => {
                let dir = child.attribute("dir").unwrap_or("horz");
                effect = TransitionEffect::Blinds {
                    direction: if dir == "horz" { TransitionDirection::Horizontal } else { TransitionDirection::Vertical },
                };
            }
            "checker" => {
                let dir = child.attribute("dir").unwrap_or("horz");
                effect = TransitionEffect::Checker {
                    direction: if dir == "horz" { TransitionDirection::Horizontal } else { TransitionDirection::Vertical },
                };
            }
            "comb" => {
                let dir = child.attribute("dir").unwrap_or("horz");
                effect = TransitionEffect::Comb {
                    direction: if dir == "horz" { TransitionDirection::Horizontal } else { TransitionDirection::Vertical },
                };
            }
            "cover" => {
                let dir = parse_8way_dir(child.attribute("dir").unwrap_or("l"));
                effect = TransitionEffect::Cover { direction: dir };
            }
            "pull" => {
                let dir = parse_8way_dir(child.attribute("dir").unwrap_or("l"));
                effect = TransitionEffect::Pull { direction: dir };
            }
            "push" => {
                let dir = parse_4way_dir(child.attribute("dir").unwrap_or("l"));
                effect = TransitionEffect::Push { direction: dir };
            }
            "uncover" => {
                let dir = parse_8way_dir(child.attribute("dir").unwrap_or("l"));
                effect = TransitionEffect::Uncover { direction: dir };
            }
            "wipe" => {
                let dir = parse_4way_dir(child.attribute("dir").unwrap_or("l"));
                effect = TransitionEffect::Wipe { direction: dir };
            }
            "strips" => {
                let dir = child.attribute("dir").unwrap_or("ld");
                effect = TransitionEffect::Strips {
                    direction: match dir {
                        "lu" => TransitionCornerDirection::LeftUp,
                        "rd" => TransitionCornerDirection::RightDown,
                        "ru" => TransitionCornerDirection::RightUp,
                        _ => TransitionCornerDirection::LeftDown,
                    },
                };
            }
            "split" => {
                let orient = child.attribute("orient").unwrap_or("horz");
                let dir = child.attribute("dir").unwrap_or("out");
                effect = TransitionEffect::Split {
                    orientation: if orient == "horz" { TransitionOrientation::Horizontal } else { TransitionOrientation::Vertical },
                    direction: if dir == "in" { TransitionInOutDirection::In } else { TransitionInOutDirection::Out },
                };
            }
            "zoom" => {
                let dir = child.attribute("dir").unwrap_or("out");
                effect = TransitionEffect::Zoom {
                    direction: if dir == "in" { TransitionInOutDirection::In } else { TransitionInOutDirection::Out },
                };
            }
            "wheel" => {
                let spokes: u32 = child.attribute("spokes").and_then(|v| v.parse().ok()).unwrap_or(4);
                effect = TransitionEffect::Wheel { spokes };
            }
            "diamond" => { effect = TransitionEffect::Diamond; }
            "dissolve" => { effect = TransitionEffect::Dissolve; }
            "flash" => { effect = TransitionEffect::Flash; }
            "newsflash" => { effect = TransitionEffect::Newsflash; }
            "plus" => { effect = TransitionEffect::Plus; }
            "randomBar" => {
                let dir = child.attribute("dir").unwrap_or("horz");
                effect = TransitionEffect::RandomBar {
                    direction: if dir == "horz" { TransitionDirection::Horizontal } else { TransitionDirection::Vertical },
                };
            }
            "wedge" => { effect = TransitionEffect::Wedge; }
            "random" => { effect = TransitionEffect::Random; }
            // PowerPoint 2013+ transitions
            "conveyor" => { effect = TransitionEffect::Pan { direction: TransitionDirection8Way::Left }; }
            "doors" => { effect = TransitionEffect::Split { orientation: TransitionOrientation::Horizontal, direction: TransitionInOutDirection::Out }; }
            "fall" | "flip" => {
                let dir = child.attribute("dir").unwrap_or("l");
                effect = TransitionEffect::Flip { direction: if dir == "l" { TransitionDirection::Left } else { TransitionDirection::Right } };
            }
            "flythrough" => { effect = TransitionEffect::Fade; }
            "gallery" => {
                let dir = child.attribute("dir").unwrap_or("l");
                effect = TransitionEffect::Gallery { direction: if dir == "l" { TransitionDirection::Left } else { TransitionDirection::Right } };
            }
            "glitter" => { effect = TransitionEffect::Honeycomb; }
            "honeycomb" => { effect = TransitionEffect::Honeycomb; }
            "morph" => {
                let option = child.attribute("option").unwrap_or("object");
                effect = TransitionEffect::Morph {
                    option: match option {
                        "words" => MorphOption::ByWord,
                        "chars" => MorphOption::ByChar,
                        _ => MorphOption::ByObject,
                    },
                };
            }
            "pan" => {
                let dir = parse_8way_dir(child.attribute("dir").unwrap_or("l"));
                effect = TransitionEffect::Pan { direction: dir };
            }
            "prism" => { effect = TransitionEffect::Flip { direction: TransitionDirection::Left }; }
            "reveal" => { effect = TransitionEffect::Cover { direction: TransitionDirection8Way::Left }; }
            "ripple" => {
                let dir = parse_4way_dir(child.attribute("dir").unwrap_or("ctr"));
                effect = TransitionEffect::Ripple { direction: dir };
            }
            "rotate" => { effect = TransitionEffect::Rotate; }
            "shred" => {
                let dir = child.attribute("dir").unwrap_or("fwd");
                effect = TransitionEffect::Shred {
                    direction: if dir == "fwd" { TransitionShredDirection::Forward } else { TransitionShredDirection::Backward },
                };
            }
            "switch" => {
                let dir = child.attribute("dir").unwrap_or("l");
                effect = TransitionEffect::Switch { direction: if dir == "l" { TransitionDirection::Left } else { TransitionDirection::Right } };
            }
            "vortex" => {
                let dir = parse_4way_dir(child.attribute("dir").unwrap_or("l"));
                effect = TransitionEffect::Vortex { direction: dir };
            }
            "warp" => { effect = TransitionEffect::Warp; }
            "wind" => {
                let dir = child.attribute("dir").unwrap_or("l");
                effect = TransitionEffect::Wind { direction: if dir == "l" { TransitionDirection::Left } else { TransitionDirection::Right } };
            }
            _ if !tag.is_empty() && tag != "sndAc" && tag != "extLst" => {
                effect = TransitionEffect::Other(tag.to_string());
            }
            _ => {}
        }
    }

    SlideTransition { effect, duration_ms, advance_on_click, advance_after_ms, sound }
}

fn parse_transition_sound(node: Node) -> Option<TransitionSound> {
    for child in node.children() {
        if child.tag_name().name() == "stSnd" {
            let mut relationship_id = None;
            let mut preset = None;
            let loop_sound = child.attribute("loop").map(|v| v == "1").unwrap_or(false);
            let stop_previous = child.attribute("isBuiltIn").map(|v| v == "0").unwrap_or(false);
            let mut is_builtin = false;

            for sub in child.children() {
                match sub.tag_name().name() {
                    "snd" => {
                        relationship_id = sub.attribute_ns(
                            "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
                            "embed",
                        ).or_else(|| sub.attribute("r:embed")).map(str::to_string);
                        is_builtin = sub.attribute("builtIn").map(|v| v == "1").unwrap_or(false);
                    }
                    _ => {}
                }
            }

            return Some(TransitionSound { relationship_id, preset, loop_sound, stop_previous, is_builtin });
        }
    }
    None
}

fn parse_4way_dir(dir: &str) -> TransitionDirection4Way {
    match dir {
        "r" => TransitionDirection4Way::Right,
        "u" => TransitionDirection4Way::Up,
        "d" => TransitionDirection4Way::Down,
        _ => TransitionDirection4Way::Left,
    }
}

fn parse_8way_dir(dir: &str) -> TransitionDirection8Way {
    match dir {
        "r" => TransitionDirection8Way::Right,
        "u" => TransitionDirection8Way::Up,
        "d" => TransitionDirection8Way::Down,
        "lu" => TransitionDirection8Way::LeftUp,
        "ld" => TransitionDirection8Way::LeftDown,
        "ru" => TransitionDirection8Way::RightUp,
        "rd" => TransitionDirection8Way::RightDown,
        _ => TransitionDirection8Way::Left,
    }
}
