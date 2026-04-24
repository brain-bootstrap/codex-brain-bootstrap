## 📋 What does this PR do?

<!-- A clear, one-paragraph description of your change. What problem does it solve? -->

## 🏷️ Type of change

<!-- Check the one that applies: -->

- [ ] 🔍 **Stack detection** — new language/framework/package manager in `discover.sh`
- [ ] 🎓 **Skill** — new skill in `.agents/skills/`
- [ ] 🪝 **Hook** — new or improved lifecycle hook
- [ ] 📏 **Rule** — new rule in `.codex/rules/`
- [ ] 🤖 **Agent** — new subagent in `.codex/agents/`
- [ ] 📚 **Documentation** — README, DETAILED_GUIDE, knowledge docs, examples
- [ ] 🐛 **Bug fix** — something was broken, now it isn't
- [ ] ♻️ **Refactor** — code improvement with no behavior change
- [ ] 🔧 **Chore** — CI, scripts, configs, maintenance

## 🧪 How was this tested?

<!-- Describe how you verified your change works. Examples: -->
<!-- - Ran `bash brain/scripts/validate.sh` — 80+ checks pass -->
<!-- - Tested in a fresh repo with `$bootstrap` -->
<!-- - Added a dummy `.dart` file and ran `discover.sh` -->

## ✅ PR Checklist

<!-- You MUST check every applicable box before requesting review. -->

- [ ] `bash brain/scripts/validate.sh` passes — **0 failures**
- [ ] Changes are **domain-agnostic** (no company names, no project-specific logic)
- [ ] New files registered in `brain/scripts/validate.sh` (if applicable)
- [ ] Documentation updated (README / DETAILED_GUIDE / relevant `brain/*.md`)
- [ ] Shell scripts have `#!/bin/bash` shebang + `set -euo pipefail`
- [ ] Hook scripts are executable (`chmod +x .codex/hooks/your-hook.sh`)
- [ ] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, etc.)
- [ ] Placeholders use `{{UPPER_SNAKE}}` syntax (not hardcoded values)
- [ ] Skill `description:` field contains triggering conditions only (not a workflow summary)
- [ ] Tested in a real or fresh test repo (not just the template itself)

## 📸 Screenshots / Output (optional)

<!-- If your change affects terminal output, validator results, or discovery output — paste it here. -->

## 🔗 Related Issues

<!-- Link to any related issues: Fixes #123, Relates to #456 -->
