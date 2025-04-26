# Git + SSH Setup (Windows & Linux)

> Set up Git with separate SSH keys for personal and work projects.

---

## 1. Install SSH (or Check if Installed)

- If using Git Bash or WSL, SSH is already included.  
- On native Windows, install **OpenSSH** via *Windows Features*.

Check if SSH is installed:

```bash
ssh -V
```
---

## 2. Create SSH Keys

Generate two SSH keys: one for personal use and one for work.

```bash

cd ~/
mkdir .ssh
# Personal key
ssh-keygen -t ed25519 -C "your-personal-email@example.com" -f .ssh/personal
# Work key
ssh-keygen -t ed25519 -C "your-work-email@example.com" -f .ssh/work
```

This will create:

```
~/.ssh/personal     and     ~/.ssh/personal.pub  
~/.ssh/work         and     ~/.ssh/work.pub
```

---

## 3. Add Your SSH Keys to GitHub

Copy your public keys:

```bash
cat ~/.ssh/personal.pub
cat ~/.ssh/work.pub
```

Add them to GitHub:

- Go to **GitHub Settings** → **SSH and GPG keys** → **New SSH key**.
- Upload:
  - Personal key to your personal GitHub account.
  - Work key to your work GitHub account.

---

## 4. Create `.ssh/config` File

Edit or create `~/.ssh/config`:

```bash
nano ~/.ssh/config
```

Add:

```bash
# Personal GitHub
Host pers
  HostName github.com
  User git
  IdentityFile ~/.ssh/personal
  IdentitiesOnly yes

# Work GitHub
Host work
  HostName github.com
  User git
  IdentityFile ~/.ssh/work
  IdentitiesOnly yes
```

This setup lets you connect using `pers` and `work` as shortcuts.

---

## 5. Set Up Git Configs

In your home directory, configure `.gitconfig`:

```ini
[includeIf "gitdir:~/TREE/"]
  path=~/.gitconfig-personal

[includeIf "gitdir:~/Work/"]
  path=~/.gitconfig-work

[user]
  email = your-personal-email@example.com
  name = YourPersonalName

[core]
  sshCommand = ssh
```

Create `.gitconfig-personal`:

```ini
[user]
  name = YourPersonalName
  email = your-personal-email@example.com

[core]
  sshCommand = ssh -i ~/.ssh/personal
```

Create `.gitconfig-work`:

```ini
[user]
  name = YourWorkName
  email = your-work-email@example.com

[core]
  sshCommand = ssh -i ~/.ssh/work
```

---

## 6. Clone Repositories Correctly

Use your configured aliases:

- For personal projects:

```bash
git clone pers:username/repo.git
```

- For work projects:

```bash
git clone work:orgname/repo.git
```

Git will automatically use the correct SSH key and Git identity.
