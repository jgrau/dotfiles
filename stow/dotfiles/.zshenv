# Package-provided session environment (Nix owns software, not this file).
if [ -r /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ]; then
  . /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
fi
