<!-- TOC -->

- [Contributing](#contributing)
- [About VSCode](#about-vscode)

<!-- TOC -->

# Contributing

> [OPTIONAL] Configure authentication on your account to use the SSH protocol instead of HTTP. See this [tutorial](https://confluence.atlassian.com/bitbucketserver/ssh-access-keys-for-system-use-776639781.html)

* Install git and other [requirements](REQUIREMENTS.md).

When someone wants to contribute to improvements in this repository, the following steps must be performed.

* Clone the repository to your computer, with the following command:

```bash
git clone git@github.com:aeciopires/custom-argocd.git
```

* Create a branch using the following command:

```bash
git checkout -b BRANCH_NAME
```

* Make sure it is the correct branch, using the following command:

```bash
git branch
```

* The branch with an '*' before the name will be used.
* Make the necessary changes.
* Test your changes.
* Commit your changes to the newly created branch.
* Submit the commits to the remote repository with the following command:

```bash
git push --set-upstream origin BRANCH_NAME
```

* Create a Pull Request (PR) for the `main` branch of the repository. Watch this [tutorial](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork).
* Update the content with the reviewers suggestions (if necessary).
* After your PR has been approved and merged, update the changes in your local repository with the following commands:

```bash
git checkout main
git pull upstream main
```

* Remove the local branch after approval and merge from your PR, using the following command:

```bash
git branch -d BRANCH_NAME
```

# About VSCode

Use a IDE (Integrated Development Environment) or text editor of your choice. By default, the use of VSCode is recommended.

VSCode (https://code.visualstudio.com), combined with the following plugins, helps the editing/review process, mainly allowing the preview of the content before the commit, analyzing the Markdown syntax and generating the automatic summary, as the section titles are created/changed.

* Markdown-lint: https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint
* Markdown-toc: https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-toc
* Markdown-all-in-one: https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one

Additional plugins:

* Gitlens: https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens
* Docker: https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker
* YAML: https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml

Themes for VSCode:

* https://vscodethemes.com/
* https://code.visualstudio.com/docs/getstarted/themes
* https://dev.to/thegeoffstevens/50-vs-code-themes-for-2020-45cc