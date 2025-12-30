// JavaScript Example - PersistenceAI Installation
// This file demonstrates JavaScript usage

const installPersistenceAI = async () => {
  const response = await fetch('https://persistence-ai.github.io/Landing/install');
  const script = await response.text();
  return script;
};

module.exports = { installPersistenceAI };
