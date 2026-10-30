# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [2.0.0] - 2026-10-30

A rewrite focused on correctness across distributions, lockout safety and automated testing.

### Added
- `preflight` role: supported-OS, controller-version and SSH lockout checks before any change.
- Molecule scenario covering converge, idempotence and 20+ live-state assertions; GitHub Actions
  matrix on Ubuntu 22.04/24.04, Debian 12/13, Rocky Linux 9 and CentOS Stream 9, plus yamllint and ansible-lint
  (production profile).
- `meta/argument_specs.yml` for every role.
- Safe SSH port migration (firewall pre-opens the port, connection is moved mid-run), SELinux
  port labelling, and Ubuntu `ssh.socket` handling.
- Post-quantum SSH key exchange selected by detected OpenSSH version; removal of weak DH moduli.
- Per-source SSH rate limiting, source-restricted and IPv6 firewall rules.
- fail2ban incremental bans and `recidive` jail.
- `dnf-automatic` for the RHEL family, EPEL handling, auditd rule set, kernel module blacklist.
- Additional managed users (`users_managed`).
- node_exporter checksum verification, multi-architecture support, in-place upgrades and
  systemd sandboxing.
- LICENSE, SECURITY.md, Makefile, pre-commit hooks, Dependabot.

### Changed
- Firewall moved from ufw/firewalld to a single declarative nftables ruleset.
- sshd settings moved to a `sshd_config.d/00-hardening.conf` drop-in so cloud-init cannot override them.
- Roles renamed for consistent variable prefixes: `ssh_hardening` → `sshd`, `monitoring` → `node_exporter`.
- All variables now live in role defaults with OS-specific values in `vars/`.
- Docker installed via deb822 / dnf repositories for the right distribution; published ports bind to
  `127.0.0.1` by default.
- `ansible.cfg` uses `StrictHostKeyChecking=accept-new` instead of disabling host key checking.

### Fixed
- Debian and RHEL hosts were rejected by the OS check.
- Default settings locked out both the admin user (no key) and Ansible's connection user.
- RHEL failures: `sudo` group, `auditd` package name, Debian-only packages, missing Docker install.
- Non-idempotent runs (`ufw reset` on every run, timestamp in the marker file).
- `requirements.yml` listed `ansible.builtin`, which cannot be installed from Galaxy.
- Managed users without `groups` failed on ansible-core 2.21 (`append` now requires `groups`).

## [1.0.0] - 2026-04-04

- Initial release.

[2.0.0]: https://github.com/anastanveer653/ansible-linux-server-automation/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/anastanveer653/ansible-linux-server-automation/releases/tag/v1.0.0
