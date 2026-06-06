# Git module

Git Home-Manager module. Sets up username, email, some basic configuration and aliases.

## Options

| Option | Type | Default | Description |
| :----: | :--: | :-----: | :---------: |
| `enable` | bool | false | Enable or disable configuration from this module |
| `userName` | str | `thalin` | Maps directly to the [`programs.git.userName`](https://mynixos.com/home-manager/option/programs.git.userName) option |
| `userEmail` | str | `28450+thalin@users.noreply.github.com` | Maps directly to the [`programs.git.userEmail`](https://mynixos.com/home-manager/option/programs.git.userEmail) option |

## Aliases

### Git Aliases

| Alias | Action |
| :---: | :----: |
| `it` | Initialize a new empty repo with whatever contents are inside. Allows no contents. |
| `cai` / `commit-ai` | Analyze changes in the staging area using `agy` or `gemini` and commit with the generated message (interactive). |

### Shell Aliases

| Alias | Action |
| :---: | :----: |
| `gac` / `gai` | Run `git cai` to commit using AI-generated messages. |

## Config

* Auto set up remote branch if the remote doesn't already have the branch we're pushing
* Set the default branch to `main`.
