/// Slide transition and per-element animation definitions.

// ── Transition (between slides) ───────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq)]
pub enum TransitionKind {
    None,
    Fade,
    SlideLeft,
    SlideRight,
    SlideUp,
    SlideDown,
    ZoomIn,
    ZoomOut,
    Flip,
    Dissolve,
}

impl Default for TransitionKind {
    fn default() -> Self {
        TransitionKind::None
    }
}

/// Easing function for animations.
#[derive(Debug, Clone, PartialEq, Default)]
pub enum Easing {
    #[default]
    Linear,
    EaseIn,
    EaseOut,
    EaseInOut,
    /// cubic-bezier(x1, y1, x2, y2)
    CubicBezier(f64, f64, f64, f64),
}

/// A slide-to-slide transition.
#[derive(Debug, Clone, Default)]
pub struct Transition {
    pub kind: TransitionKind,
    pub duration_ms: u32,
    pub easing: Easing,
}

impl Transition {
    pub fn none() -> Self {
        Self::default()
    }

    pub fn fade(duration_ms: u32) -> Self {
        Self {
            kind: TransitionKind::Fade,
            duration_ms,
            easing: Easing::EaseInOut,
        }
    }

    pub fn slide_left(duration_ms: u32) -> Self {
        Self {
            kind: TransitionKind::SlideLeft,
            duration_ms,
            easing: Easing::EaseInOut,
        }
    }
}

// ── Element animation (entrance / exit / emphasis) ────────────────────────────

#[derive(Debug, Clone, PartialEq)]
pub enum AnimationEffect {
    // Entrance
    FadeIn,
    FlyInLeft,
    FlyInRight,
    FlyInTop,
    FlyInBottom,
    ZoomIn,
    // Exit
    FadeOut,
    FlyOutLeft,
    FlyOutRight,
    ZoomOut,
    // Emphasis
    Pulse,
    Shake,
    Spin,
    Bounce,
}

#[derive(Debug, Clone, PartialEq)]
pub enum AnimationTrigger {
    /// Fires automatically after the previous animation completes.
    AfterPrevious,
    /// Fires at the same time as the previous animation.
    WithPrevious,
    /// Requires a manual click / keypress to advance.
    OnClick,
}

impl Default for AnimationTrigger {
    fn default() -> Self {
        AnimationTrigger::OnClick
    }
}

/// A single element animation attached to a shape on a slide.
#[derive(Debug, Clone)]
pub struct ElementAnimation {
    /// The shape id this animation targets.
    pub shape_id: String,
    pub effect: AnimationEffect,
    pub trigger: AnimationTrigger,
    pub delay_ms: u32,
    pub duration_ms: u32,
    pub easing: Easing,
    /// How many times to repeat (0 = infinite).
    pub repeat: u32,
}

impl ElementAnimation {
    pub fn new(shape_id: impl Into<String>, effect: AnimationEffect) -> Self {
        Self {
            shape_id: shape_id.into(),
            effect,
            trigger: AnimationTrigger::OnClick,
            delay_ms: 0,
            duration_ms: 500,
            easing: Easing::EaseOut,
            repeat: 1,
        }
    }

    pub fn with_delay(mut self, delay_ms: u32) -> Self {
        self.delay_ms = delay_ms;
        self
    }

    pub fn with_duration(mut self, duration_ms: u32) -> Self {
        self.duration_ms = duration_ms;
        self
    }

    pub fn with_trigger(mut self, trigger: AnimationTrigger) -> Self {
        self.trigger = trigger;
        self
    }
}

/// All animations for a single slide, in playback order.
#[derive(Debug, Default, Clone)]
pub struct SlideAnimations {
    pub transition: Transition,
    pub elements: Vec<ElementAnimation>,
}

impl SlideAnimations {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn set_transition(&mut self, t: Transition) {
        self.transition = t;
    }

    pub fn add_element_animation(&mut self, anim: ElementAnimation) {
        self.elements.push(anim);
    }
}
