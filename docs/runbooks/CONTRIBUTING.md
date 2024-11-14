---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Contributing Runbooks
type: Informational
runbook-name: "Contributing Runbooks"
description: How to contribute to these runbooks
link: /CONTRIBUTING.html
service: Runbook needs to be updated with service
parent: Armada Runbooks

---

Informational
{: .label }

# Contributions

Contributions are welcome! Please follow the process below to contribute.
This outlines basic Steps/Git Commands to make a change to code in GitHub Enterprise

---

# Pre-requisites

1. Request USAM Access to the GitHub Area.
2. For Windows, install Git Bash or git alternative. For the purposes of this runbook, Git Bash is used.

---

# Setup GitHub Profile and Terminal with SSH Keys

Log onto IBM GitHub Enterprise: https://github.ibm.com
On the top right corner, click on the dropdown to view your profiles settings.
On the list of your personal settings that appear, click on 'SSH keys'.
Add your SSH key into your profile here. (SSH key normally found on Windows machine
eg. C:\Users\\(user_name)\\.ssh\ )

On windows machines you need to set up your terminal with your SSH key also. Open a gitBash terminal and set up the SSH keys:

1. **eval $(ssh-agent -s)**
2. **ssh-add ~/.ssh/(ssh_key_filename)**

# Create a fork

###### (Creating a personal remote copy of the repository.)
  1. Find the repository you want to contribute to in your browser.
  2. Click on the "Fork" button at the top right.
  3. You should be taken in the browser to your fork once it has been created.

For more info on creating forks, see [this](https://help.github.com/articles/fork-a-repo/) page.

# Create a local clone of the fork that you created into a new directory

1. Open Terminal (for Mac and Linux users) or Git Bash (for Windows users).
2. Navigate to a new directory and create a folder where you want to store your local repo, eg. C:/Git/(myRepoName).
  You need to get the repository to clone from GitHub Enterprise.
3. On GitHub Enterprise, navigate to your fork of the repository.
4. In the right sidebar of your fork's repository page, copy the clone URL for your fork.
5. Edit that URL to include the git user in the git clone command eg.
URL: https://github.ibm.com/(forkname)/repository.git
=> **git clone git@github.ibm.com:(forkname)/repository.git**
4. Press Enter and your local clone will be created into a new folder.

# Configure Git to sync your fork with the original repository.

###### (Pulling changings from the original remote repo to the local clone of your fork. May not be neccessary if the repo is rarely edited.)

When you fork a project in order to propose changes to the original repository, you can configure Git to pull changes from the original, or upstream, repository into the local clone of your fork.

1. In a terminal/command prompt window navigate to your local repository directory. Enter: **git remote -v**
 You'll see the current configured remote repository for your fork.
2. Enter:  eg. **git remote add --track master upstream git@github.ibm.com:(OriginalRepository)/repository.git**
3. To verify the new upstream repository you've specified for your fork, enter: **git remote -v** again.
 You should see the URL for your fork as origin, and the URL for the original repository as upstream.
4. Sync your local copy of the fork whenever neccessary using the following steps:
      * Create a local branch "upstream/master": **git fetch upstream**
      * Move to the master branch: **git checkout master**
      * Merge the two branches: **git merge upstream/master**

For more info on syncing forks, see [this](https://help.github.com/articles/syncing-a-fork/) page.

# Create a branch to make your changes

###### (It is not neccessary to create a branch to make changes however it is recommended. This allows you to work on different code changes simultaneously and separately and for your different changes to be accepted independently.)

1. In a terminal/command prompt window navigate to your local repository directory.
2. To list all existing branches, enter: **git branch -av**
3. To create a new branch, enter: **git checkout -b (your_new_branch_name)**

For more info on Branches, see [this](https://github.com/Kunena/Kunena-Forum/wiki/Create-a-new-branch-with-git-and-manage-branches) page.

# Changes to the code

Once you have completed your changes and saved them, you are ready to push your code.

# Push your code up to the Forked repository

After you have made your changes locally and have tested, you are ready to push them up to the repository.

1. Firstly, review what changes have been made on your branch by running **git status**
 This will list all of the changes between your local and the remote repository.
2. Add all changes using **git add .** or you can add an individual file by entering **git add -p (file)**
3. Commit the changes and include a message describing the change: **git commit -m "with your message here"**
4. Push your changes to your branch: **git push origin (your_branch_name)**
5. If you use just **git push** all branches will be pushed.

# Creating a pull request

###### (Adding your fork changes to the original project.)
  1. Go to your fork repository in your browser.
  2. Click on a small green button with the pop up label "Compare, review, create a pull request".
  3. Click "Create pull request".
  4. Your changes can now be seen by owners/developers of the project and the  can accept your pull request and merge your branch.
  5. If your changes are accepted you can delete your fork.

For more info on using pull requests, see [this](https://help.github.com/articles/using-pull-requests/) page.
