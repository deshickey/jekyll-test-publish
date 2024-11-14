---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Explains how to fork, sync, branch and create a pull request.
service: Runbook needs to be updated with service
title: How to Contribute to a Github Enterprise Project
runbook-name: "How to Contribute to a Github Enterprise Project"
link: /contributing_to_ghe.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }


# **How to Contribute to a Github Enterprise Project**

## *How to fork a repository, sync your fork and create a pull request.*

### 1. Creating a fork

###### (Creating a personal remote copy of the repository.)
  1. Find the repository you want to contribute to in your browser.
  2. Click on the "Fork" button at the top right.
  3. You should be taken in the browser to your fork once it has been created.
  4. Copy the "clone URL" to your clipboard.
  5. Clone this fork with the command: `git clone <clone URL>`.

For more info on creating forks, see [this](https://help.github.com/articles/fork-a-repo/) page.

### 2. Syncing your fork

###### (Pulling changings from the original remote repo to the local clone of your fork. May not be neccessary if the repo is rarely edited.)
  1. Copy the clone URL of the original repo.
  2. Move to the clone of your fork in the terminal.
  3. Use the command `git remote -v` to show the URLs of related remote repositories. Currently the only remote repo is the origin.
  4. Add the original repo under the name upstream with the command: `git remote add upstream <clone URL of original repo>`.
  5. Sync your local copy of the fork whenever necessary using the following steps:
      * Create a local branch "upstream/master": `git fetch upstream`.
      * Move to the master branch: `git checkout master`.
      * Merge the two branches: `git merge upstream/master`.

For more info on syncing forks, see [this](https://help.github.com/articles/syncing-a-fork/) page.

### 3. Make changes by creating and editing a branch

###### (It is not necessary to create a branch to make changes however it is recommended. This allows you to work on different code changes simultaneously and separately and for your different changes to be accepted independently.)
  1.  Create and switch to a new branch with: `git checkout -b <name_of_your_new_branch>`.
  2. To add your changes to origin (the remote copy of your fork). First make sure you are in the branch you want to commit changes from then use `git add .` followed by `git commit`, then `git push origin <name_of_your_new_branch>`.
  3. If you use just `git push` all branches will be pushed.

For more info on Branches, see [this](https://github.com/Kunena/Kunena-Forum/wiki/Create-a-new-branch-with-git-and-manage-branches) page.

### 4. Creating a pull request

###### (Adding your fork changes to the original project.)
  1. Go to your fork repository in your browser.
  2. Click on a small green button with the pop up label "Compare, review, create a pull request".
  3. Click "Create pull request".
  4. Your changes can now be seen by owners/developers of the project and the  can accept your pull request and merge your branch.
  5. If your changes are accepted you can delete your fork.

For more info on using pull requests, see [this](https://help.github.com/articles/using-pull-requests/) page.
