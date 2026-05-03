"""Shared OpenAI-compatible client setup for llm-tools (llm-ask / llm-write / llm-extract).

Configuration via environment variables:
  LLM_PROVIDER       deepseek | kimi | openrouter | ollama   (default: deepseek)
  LLM_BASE_URL       Override base URL.
  LLM_API_KEY        Override API key (else falls back to provider-specific var).
  LLM_MODEL          Default model for `llm-ask` / `llm-extract`.
  LLM_WRITE_MODEL    Default model for `llm-write` (higher-quality tier).

Provider-specific keys looked up if LLM_API_KEY is unset:
  deepseek    -> DEEPSEEK_API_KEY
  kimi        -> MOONSHOT_API_KEY
  openrouter  -> OPENROUTER_API_KEY
  ollama      -> (none; local)
"""
import os
import sys

PROVIDERS = {
    "deepseek": {
        "base_url": "https://api.deepseek.com",
        "model": "deepseek-chat",
        "write_model": "deepseek-reasoner",
        "api_key_env": "DEEPSEEK_API_KEY",
    },
    "kimi": {
        "base_url": "https://api.moonshot.cn/v1",
        "model": "moonshot-v1-128k",
        "write_model": "moonshot-v1-128k",
        "api_key_env": "MOONSHOT_API_KEY",
    },
    "openrouter": {
        "base_url": "https://openrouter.ai/api/v1",
        "model": "deepseek/deepseek-chat",
        "write_model": "anthropic/claude-3.5-sonnet",
        "api_key_env": "OPENROUTER_API_KEY",
    },
    "ollama": {
        "base_url": "http://localhost:11434/v1",
        "model": "llama3.1",
        "write_model": "qwen2.5-coder",
        "api_key_env": None,
    },
}


def get_client(write_tier: bool = False):
    """Return (client, model_id) tuple. Imports openai lazily."""
    try:
        from openai import OpenAI
    except ImportError:
        sys.stderr.write("openai package not installed in venv. Re-run after deleting "
                         "$HOME/.local/share/llm-tools/venv to force reinstall.\n")
        sys.exit(2)

    provider = os.environ.get("LLM_PROVIDER", "deepseek").lower()
    if provider not in PROVIDERS:
        sys.stderr.write(f"unknown LLM_PROVIDER={provider!r}; "
                         f"valid: {', '.join(PROVIDERS)}\n")
        sys.exit(2)
    cfg = PROVIDERS[provider]

    base_url = os.environ.get("LLM_BASE_URL", cfg["base_url"])
    model_env = "LLM_WRITE_MODEL" if write_tier else "LLM_MODEL"
    default = cfg["write_model"] if write_tier else cfg["model"]
    model = os.environ.get(model_env, default)

    api_key = os.environ.get("LLM_API_KEY")
    if not api_key and cfg["api_key_env"]:
        api_key = os.environ.get(cfg["api_key_env"])
    if not api_key:
        api_key = "ollama-no-key" if provider == "ollama" else ""

    if not api_key:
        sys.stderr.write(f"missing API key for provider {provider!r}. "
                         f"Set LLM_API_KEY or {cfg['api_key_env']}.\n")
        sys.exit(2)

    return OpenAI(base_url=base_url, api_key=api_key), model
