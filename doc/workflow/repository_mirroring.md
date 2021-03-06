# Repository mirroring


Repository Mirroring is a way to mirror repositories from external sources.
It can be used to mirror all branches, tags, and commits that you have
in your repository.

Your mirror at GitLab will be updated automatically. You can
also manually trigger an update at most once every 5 minutes.

## Overview

Repository mirroring is very useful when, for some reason, you must use a
project from another source.

There are two kinds of repository mirroring features supported by GitLab:
**push** and **pull**. The **push** method mirrors the repository in GitLab
to another location, whereas the **pull** method mirrors an external repository
in one in GitLab.

Once the mirror repository is updated, all new branches,
tags, and commits will be visible in the project's activity feed.
Users with at least [developer access][perms] to the project can also force an
immediate update with the click of a button. This button will not be available if
the mirror is already being updated or 5 minutes still haven't passed since its last update.

A few things/limitations to consider:

- The repository must be accessible over `http://`, `https://`, `ssh://` or `git://`.
- If your HTTP repository is not publicly accessible, add authentication
  information to the URL, like: `https://username@gitlab.company.com/group/project.git`.
  In some cases, you might need to use a personal access token instead of a
  password, e.g., you want to mirror to GitHub and have 2FA enabled.
- The import will time out after 15 minutes. For repositories that take longer
  use a clone/push combination.
- The Git LFS objects will not be synced. You'll need to push/pull them
  manually.

## Use-cases

- You migrated to GitLab but still need to keep you project in another source.
  In that case, you can simply set it up to mirror to GitLab (pull) and all the
  essential history of commits, tags and branches will be available in your
  GitLab instance.
- You have old projects in another source that you don't use actively anymore,
  but don't want to remove for archiving purposes. In that case, you can create
  a push mirror so that your active GitLab repository can push its changes to the
  old location.

## Pulling from a remote repository

>[Introduced][ee-51] in GitLab Enterprise Edition 8.2.

You can set up a repository to automatically have its branches, tags, and commits
updated from an upstream repository. This is useful when a repository you're
interested in is located on a different server, and you want to be able to
browse its content and its activity using the familiar GitLab interface.

When creating a new project, you can enable repository mirroring when you choose
to import the repository from "Any repo by URL". Enter the full URL of the Git
repository to pull from and click on the **Mirror repository** checkbox.

![New project](repository_mirroring/repository_mirroring_new_project.png)

For an existing project, you can set up mirror pulling by visiting your project's
**Settings ➔ Repository** and searching for the "Pull from a remote repository"
section. Check the "Mirror repository" box and hit **Save changes** at the bottom.
You have a few options to choose from one being the user who will be the author
of all events in the activity feed that are the result of an update. This user
needs to have at least [master access][perms] to the project. Another option is
whether you want to trigger builds for mirror updates.

![Pull settings](repository_mirroring/repository_mirroring_pull_settings.png)

Since the repository on GitLab functions as a mirror of the upstream repository,
you are advised not to push commits directly to the repository on GitLab.
Instead, any commits should be pushed to the upstream repository, and will end
up in the GitLab repository automatically within a certain period of time
or when a [forced update](#forcing-an-update) is initiated.

If you do manually update a branch in the GitLab repository, the branch will
become diverged from upstream, and GitLab will no longer automatically update
this branch to prevent any changes from being lost.

![Diverged branch](repository_mirroring/repository_mirroring_diverged_branch.png)

### SSH authentication

> [Introduced][ee-2551] in GitLab Enterprise Edition Starter 9.5

If you're mirroring over SSH (i.e., an `ssh://` URL), you can authenticate using
password-based authentication, just as over HTTPS, but you can also use public
key authentication. This is often more secure than password authentication,
especially when the source repository supports [Deploy Keys][deploy-key].

To get started, navigate to **Settings ➔ Repository ➔ Pull from a remote repository**,
enable mirroring (if not already enabled) and enter an `ssh://` URL.

> **NOTE**: SCP-style URLs, e.g., `git@example.com:group/project.git`, are not
supported at this time.

Entering the URL adds two features to the page - `Fingerprints` and
`SSH public key authentication`:

![Pull settings for SSH](repository_mirroring/repository_mirroring_pull_settings_for_ssh.png)

SSH authentication is mutual. You have to prove to the server that you're
allowed to access the repository, but the server also has to prove to *you* that
it's who it claims to be. You provide your credentials as a password or public
key. The server that the source repository resides on provides its credentials
as a "host key", the fingerprint of which needs to be verified manually.

Press the `Detect host keys` button. GitLab will fetch the host keys from the
server, and display the fingerprints to you:

![Detect SSH host keys](repository_mirroring/repository_mirroring_detect_host_keys.png)

You now need to verify that the fingerprints are those you expect. GitLab.com
and other code hosting sites publish their fingerprints in the open for you
to check:

* [AWS CodeCommit](http://docs.aws.amazon.com/codecommit/latest/userguide/regions.html#regions-fingerprints)
* [Bitbucket](https://confluence.atlassian.com/bitbucket/use-the-ssh-protocol-with-bitbucket-cloud-221449711.html#UsetheSSHprotocolwithBitbucketCloud-KnownhostorBitbucket%27spublickeyfingerprints)
* [GitHub](https://help.github.com/articles/github-s-ssh-key-fingerprints/)
* [GitLab.com](https://about.gitlab.com/gitlab-com/settings/#ssh-host-keys-fingerprints)
* [Launchpad](https://help.launchpad.net/SSHFingerprints)
* [Savannah](http://savannah.gnu.org/maintenance/SshAccess/)
* [SourceForge](https://sourceforge.net/p/forge/documentation/SSH%20Key%20Fingerprints/)

Other providers will vary. If you're running on-premises GitLab, or otherwise
have access to the source server, you can securely gather the key fingerprints:

```
$ cat /etc/ssh/ssh_host*pub | ssh-keygen -E md5 -l -f -
256 MD5:f4:28:9f:23:99:15:21:1b:bf:ed:1f:8e:a0:76:b2:9d root@example.com (ECDSA)
256 MD5:e6:eb:45:8a:3c:59:35:5f:e9:5b:80:12:be:7e:22:73 root@example.com (ED25519)
2048 MD5:3f:72:be:3d:62:03:5c:62:83:e8:6e:14:34:3a:85:1d root@example.com (RSA)
```

(You may need to exclude `-E md5` for some older versions of SSH).

If you're an SSH expert and already have a `known_hosts` file you'd like to use
unaltered, then you can skip these steps. Just press the "Show advanced" button
and paste in the file contents:

![Advanced SSH host key management](repository_mirroring/repository_mirroring_pull_advanced_host_keys.png)

Once you've **carefully verified** that all the fingerprints match your trusted
source, you can press `Save changes`. This will record the host keys, along with
the person who verified them (you!) and the date:

![SSH host keys submitted](repository_mirroring/repository_mirroring_ssh_host_keys_verified.png)

When pulling changes from the source repository, GitLab will now check that at
least one of the stored host keys matches before connecting. This can prevent
malicious code from being injected into your mirror, or your password being
stolen!

To use SSH public key authentication, you'll also need to choose that option
from the authentication methods dropdown. GitLab will generate a 4096-bit RSA
key and display the public component of that key to you:

![SSH public key authentication](repository_mirroring/repository_mirroring_ssh_public_key_authentication.png)

You then need to add the public SSH key to the source repository configuration.
If the source is hosted on GitLab, you should add it as a [Deploy Key][deploy-key].
Other sources may require you to add the key to your user's `authorized_keys`
file - just paste the entire `ssh-rsa AAA.... user@host` block into the file on
its own line and save it.

Once the public key is set up on the source repository, press `Save changes` and your
mirror will begin working.

If you need to change the key at any time, you can press the `Regenerate key`
button to do so. You'll have to update the source repository with the new key
to keep the mirror running.

## How it works

Once you activate the pull mirroring feature, the mirror will be inserted into a queue.
A scheduler will start every minute and schedule a fixed amount of mirrors for update, based
on the configured maximum capacity.

If the mirror successfully updates it will be enqueued once again with a small backoff
period.

If the mirror fails (eg: branch diverged from upstream), the project's
backoff period will be penalized each time it fails up to a maximum amount of time.

## Pushing to a remote repository

>[Introduced](https://gitlab.com/gitlab-org/gitlab-ee/merge_requests/249) in GitLab Enterprise Edition 8.7.

For an existing project, you can set up mirror pushing by visiting your project's
**Settings ➔ Repository** and searching for the "Push to a remote repository"
section. Check the "Remote mirror repository" box and fill in the Git URL of the
repository to push to. Hit **Save changes** for the changes to take effect.

![Push settings](repository_mirroring/repository_mirroring_push_settings.png)

Similarly to the pull mirroring, since the upstream repository functions as a
mirror to the repository in GitLab, you are advised not to push commits directly
to the mirrored repository. Instead, all changes will end up in the mirrored repository
whenever commits are pushed to GitLab, or when a [forced update](#forcing-an-update) is initiated.

Pushes into GitLab are automatically pushed to the remote mirror 5 minutes after they come in.

In case of a diverged branch, you will see an error indicated at the
**Mirror repository** settings.

![Diverged branch](repository_mirroring/repository_mirroring_diverged_branch_push.png)

## Setting up a mirror from GitLab to GitHub

To set up a mirror from GitLab to GitHub, you need to follow these steps:

1. Create a [GitHub personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) with the "public_repo" box checked:
    
    ![edit personal access token GitHub](repository_mirroring/repository_mirroring_github_edit_personal_access_token.png)

1. Fill in the "Git repository URL" with the personal access token replacing the password `https://GitHubUsername:GitHubPersonalAccessToken@github.com/group/project.git`:

    ![push to remote repo](repository_mirroring/repository_mirroring_gitlab_push_to_a_remote_repository.png)

1. Save
1. And either wait or trigger the "Update Now" button:

    ![update now](repository_mirroring/repository_mirroring_gitlab_push_to_a_remote_repository_update_now.png)

## Forcing an update

While mirrors are scheduled to update automatically, you can always force an update (either **push** or
**pull**) by using the **Update now** button which is exposed in various places:

- in the commits page
- in the branches page
- in the tags page
- in the **Mirror repository** settings page

## Using both mirroring methods at the same time

Currently there is no bidirectional support without conflicts. That means that
if you configure a repository to both pull and push to a second one, there is
no guarantee that it will update correctly on both remotes.
You can try [configuring custom Git hooks][hooks] on the GitLab server in order
to resolve this issue.


[ee-51]: https://gitlab.com/gitlab-org/gitlab-ee/merge_requests/51
[ee-2551]: https://gitlab.com/gitlab-org/gitlab-ee/merge_requests/2551
[perms]: ../user/permissions.md
[hooks]: https://docs.gitlab.com/ee/administration/custom_hooks.html
[deploy-key]: ../ssh/README.md#deploy-keys
