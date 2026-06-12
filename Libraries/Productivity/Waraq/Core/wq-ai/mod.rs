pub mod agent;
pub mod completion;
pub mod context;
pub mod diff;
pub mod prompt;

pub use agent::{Agent, AgentPlan, AgentResult, AgentTask};
pub use completion::{
    CompletionEngine, CompletionRequest, CompletionResponse, InlineSuggestion, SuggestionKind,
};
pub use context::{AiContext, ContextWindow, CursorContext, SemanticScope};
pub use diff::SuggestionDiff;
pub use prompt::PromptBuilder;
