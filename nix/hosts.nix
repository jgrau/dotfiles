# Shared configuration, explicit per-machine software and identity.
{
  jgrau-m5 = {
    hostName = "Jonass-MacBook-Pro";
    computerName = "Jonas’s MacBook Pro";
    disableSleep = null; # Leave this portable Mac’s sleep policy unmanaged.
    manageNix = true;
    manageHomebrew = true;
    desktopApps = true;
    developmentExtras = true;
  };
  jgrau-m1 = {
    hostName = "jgrau-mbp";
    computerName = "Jonas Grau's MacBook Pro";
    disableSleep = true; # Stationary, plugged-in, lid-closed remote host.
    manageNix = false; # Determinate Nix owns the daemon.
    manageHomebrew = false; # Leave existing applications and formulae alone.
    desktopApps = false;
    developmentExtras = false;
  };
}
