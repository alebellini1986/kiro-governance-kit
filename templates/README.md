# Templates

Pre-assembled workspace configurations for quick onboarding.

## Usage

Copy a template to a new workspace to start with a pre-configured `.kiro/` setup:

```bash
cp -r templates/example-workspace/.kiro /path/to/your/project/.kiro
```

## Creating Templates

1. Set up a workspace with the desired steering, skills, and hooks
2. Copy the `.kiro/` directory into a new folder under `templates/`
3. Add a README explaining the template's purpose

Templates are optional — most teams just use `scripts/install.sh --team <name>`.
