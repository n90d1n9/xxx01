use roxmltree::Node;
use crate::models::animation::*;

/// Parse a `<p:timing>` element from a slide into SlideAnimations.
pub fn parse_timing(node: Node) -> SlideAnimations {
    let mut result = SlideAnimations::default();

    for child in node.children() {
        if child.tag_name().name() == "tnLst" {
            for seq_node in child.children() {
                if seq_node.tag_name().name() == "seq" {
                    let concurrent = seq_node.attribute("concurrent").map(|v| v == "1").unwrap_or(false);
                    let next_ac = seq_node.attribute("nextAc").unwrap_or("");

                    // Check if this is the main sequence
                    let is_main = seq_node.children()
                        .any(|c| c.tag_name().name() == "cTn" && {
                            c.children().any(|cc| {
                                cc.tag_name().name() == "stCondLst"
                                    && cc.children().any(|ccc| {
                                        ccc.tag_name().name() == "cond"
                                            && ccc.attribute("evt") == Some("onBegin")
                                            && ccc.attribute("delay") == Some("indefinite")
                                    })
                            })
                        });

                    let animations = parse_sequence_animations(seq_node);
                    if is_main || result.interactive_sequences.is_empty() {
                        result.main_sequence.extend(animations);
                    } else {
                        let trigger_id = extract_trigger_shape_id(seq_node);
                        result.interactive_sequences.push(InteractiveSequence {
                            trigger_shape_id: trigger_id,
                            animations,
                        });
                    }
                }
            }
        }
    }
    result
}

/// Extract animations from a `<p:seq>` or `<p:par>` sequence node.
fn parse_sequence_animations(node: Node) -> Vec<Animation> {
    let mut animations = Vec::new();
    for child in node.children() {
        match child.tag_name().name() {
            "cTn" => {
                for ctn_child in child.children() {
                    if ctn_child.tag_name().name() == "childTnLst" {
                        for par_node in ctn_child.children() {
                            animations.extend(parse_par_animations(par_node));
                        }
                    }
                }
            }
            _ => {}
        }
    }
    animations
}

/// Parse animations from a `<p:par>` parallel group.
fn parse_par_animations(node: Node) -> Vec<Animation> {
    let mut animations = Vec::new();
    if node.tag_name().name() != "par" { return animations; }

    for child in node.children() {
        if child.tag_name().name() == "cTn" {
            for sub_child in child.children() {
                if sub_child.tag_name().name() == "childTnLst" {
                    for effect_node in sub_child.children() {
                        if let Some(anim) = parse_animation_effect_node(effect_node) {
                            animations.push(anim);
                        }
                    }
                }
            }
        }
    }
    animations
}

/// Parse a single animation element node (set, anim, animEffect, animMotion, etc.)
fn parse_animation_effect_node(node: Node) -> Option<Animation> {
    let tag = node.tag_name().name();

    let (shape_id, effect, duration_ms, delay_ms, trigger) = match tag {
        "par" => {
            // Nested par — recurse or find animEffect
            let anims = parse_par_animations(node);
            return anims.into_iter().next();
        }
        "animEffect" => {
            let filter = node.attribute("filter").unwrap_or("");
            let transition = node.attribute("transition").unwrap_or("in");
            let (shape_id, dur, delay, trig) = extract_ctn_meta(node);
            let effect = parse_animEffect_filter(filter, transition == "in");
            (shape_id, effect, dur, delay, trig)
        }
        "anim" => {
            let (shape_id, dur, delay, trig) = extract_ctn_meta(node);
            let attr_name = node.attribute("attrName").unwrap_or("");
            let from = node.attribute("from").map(str::to_string);
            let to = node.attribute("to").map(str::to_string);
            let effect = AnimationEffect::Custom(format!("anim:{}", attr_name));
            (shape_id, effect, dur, delay, trig)
        }
        "animMotion" => {
            let (shape_id, dur, delay, trig) = extract_ctn_meta(node);
            let path_data = node.attribute("path").map(str::to_string);
            let origin_str = node.attribute("origin").unwrap_or("parent");
            let rotate = node.attribute("rAng").map(|v| v == "autoRotate").unwrap_or(false);
            let effect = AnimationEffect::MotionPath {
                path_type: if path_data.is_some() { MotionPathType::User } else { MotionPathType::Custom },
                path_data,
                origin: None,
                destination: None,
                smooth: true,
                rotate_with_path: rotate,
            };
            (shape_id, effect, dur, delay, trig)
        }
        "set" => {
            let (shape_id, dur, delay, trig) = extract_ctn_meta(node);
            (shape_id, AnimationEffect::Appear, dur, delay, trig)
        }
        "animScale" => {
            let (shape_id, dur, delay, trig) = extract_ctn_meta(node);
            (shape_id, AnimationEffect::GrowShrink { size: 1.0 }, dur, delay, trig)
        }
        "animRot" => {
            let (shape_id, dur, delay, trig) = extract_ctn_meta(node);
            (shape_id, AnimationEffect::Spin {
                amount: 360.0,
                direction: RotationDirection::Clockwise,
                auto_reverse: false,
            }, dur, delay, trig)
        }
        _ => return None,
    };

    Some(Animation {
        shape_id,
        effect,
        trigger,
        delay_ms,
        duration_ms,
        repeat_count: None,
        auto_reverse: false,
        speed: AnimationSpeed::Custom(duration_ms),
        end_action: AnimationEndAction::Hold,
        target: AnimationTarget::WholeShape,
        accel: 0.0,
        decel: 0.0,
        hide_after: false,
        extra: None,
    })
}

/// Extract shape ID, duration, delay, and trigger from a cTn-containing node.
fn extract_ctn_meta(node: Node) -> (Option<String>, u64, u64, AnimationTrigger) {
    let mut shape_id = None;
    let mut duration_ms: u64 = 2000;
    let mut delay_ms: u64 = 0;
    let mut trigger = AnimationTrigger::OnClick;

    for child in node.children() {
        match child.tag_name().name() {
            "cTn" => {
                duration_ms = child.attribute("dur")
                    .and_then(|v| if v == "indefinite" { None } else { v.parse().ok() })
                    .unwrap_or(2000);

                for ctn_child in child.children() {
                    if ctn_child.tag_name().name() == "stCondLst" {
                        for cond in ctn_child.children() {
                            if cond.tag_name().name() == "cond" {
                                let delay_str = cond.attribute("delay").unwrap_or("0");
                                delay_ms = if delay_str == "indefinite" { 0 } else {
                                    delay_str.parse().unwrap_or(0)
                                };
                                let evt = cond.attribute("evt").unwrap_or("");
                                trigger = match evt {
                                    "onBegin" | "begin" => {
                                        if delay_ms > 0 {
                                            AnimationTrigger::AfterPrevious
                                        } else {
                                            AnimationTrigger::WithPrevious
                                        }
                                    }
                                    _ => AnimationTrigger::OnClick,
                                };
                            }
                        }
                    }
                }
            }
            "tgtEl" => {
                shape_id = extract_target_shape_id(child);
            }
            _ => {}
        }
    }

    (shape_id, duration_ms, delay_ms, trigger)
}

/// Extract the shape ID from a `<p:tgtEl>` element.
fn extract_target_shape_id(node: Node) -> Option<String> {
    for child in node.children() {
        match child.tag_name().name() {
            "spTgt" | "grpSpTgt" | "graphicFrameTgt" => {
                return child.attribute("spid").map(str::to_string);
            }
            _ => {}
        }
    }
    None
}

/// Extract the trigger shape ID from a sequence node.
fn extract_trigger_shape_id(node: Node) -> Option<String> {
    for child in node.children() {
        if child.tag_name().name() == "cTn" {
            for ctn_child in child.children() {
                if ctn_child.tag_name().name() == "stCondLst" {
                    for cond in ctn_child.children() {
                        if cond.tag_name().name() == "cond" {
                            for cond_child in cond.children() {
                                if cond_child.tag_name().name() == "tgtEl" {
                                    return extract_target_shape_id(cond_child);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    None
}

/// Map an animEffect filter string to an AnimationEffect.
fn parse_animEffect_filter(filter: &str, is_entrance: bool) -> AnimationEffect {
    // Filter strings follow the pattern "TypeX(params)"
    let filter_lower = filter.to_lowercase();

    if is_entrance {
        if filter_lower.contains("blinds") {
            return AnimationEffect::Blinds { direction: Direction::Left };
        }
        if filter_lower.contains("box") {
            return AnimationEffect::Box { direction: BoxDirection::In };
        }
        if filter_lower.contains("checkerboard") {
            return AnimationEffect::Checkerboard { direction: Direction::Left };
        }
        if filter_lower.contains("circle") {
            return AnimationEffect::Circle { direction: EntranceExitDirection::In };
        }
        if filter_lower.contains("crawl") {
            return AnimationEffect::CrawlIn { from: Direction::Left };
        }
        if filter_lower.contains("dissolve") || filter_lower.contains("random") {
            return AnimationEffect::Dissolve;
        }
        if filter_lower.contains("fade") {
            return AnimationEffect::Fade;
        }
        if filter_lower.contains("fly") {
            return AnimationEffect::Fly {
                from: Direction::Down,
                smooth_start: true,
                smooth_end: false,
            };
        }
        if filter_lower.contains("wipe") {
            return AnimationEffect::Wipe { direction: Direction::Left };
        }
        if filter_lower.contains("zoom") {
            return AnimationEffect::Zoom {
                direction: ZoomDirection::In,
                origin: ZoomOrigin::Center,
            };
        }
        if filter_lower.contains("split") {
            return AnimationEffect::Split {
                orientation: Orientation::Horizontal,
                direction: SplitDirection::In,
            };
        }
        if filter_lower.contains("strips") {
            return AnimationEffect::Strips { direction: CornerDirection::LeftDown };
        }
        if filter_lower.contains("wheel") {
            return AnimationEffect::Wheel { spokes: 1 };
        }
        AnimationEffect::Appear
    } else {
        if filter_lower.contains("fade") {
            return AnimationEffect::Fade;
        }
        if filter_lower.contains("fly") {
            return AnimationEffect::FlyOut { to: Direction::Down };
        }
        if filter_lower.contains("wipe") {
            return AnimationEffect::Wipe { direction: Direction::Left };
        }
        AnimationEffect::Disappear
    }
}
