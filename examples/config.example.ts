// TypeScript Example - PersistenceAI Configuration
// This file demonstrates TypeScript usage in PersistenceAI

interface AgentConfig {
  name: string;
  model: string;
  tools: string[];
}

const buildAgent: AgentConfig = {
  name: "build",
  model: "anthropic/claude-sonnet-4",
  tools: ["write", "bash", "read"]
};

export { buildAgent, type AgentConfig };
