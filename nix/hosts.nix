# Shared configuration, explicit per-machine software and identity.
{
  Jonass-MacBook-Pro = {
    hostName = "Jonass-MacBook-Pro";
    computerName = "Jonas’s MacBook Pro";
    manageNix = true;
    manageHomebrew = true;
    desktopApps = true;
    developmentExtras = true;
  };
  jgrau-m1 = {
    hostName = "jgrau-mbp";
    computerName = "Jonas Grau's MacBook Pro";
    manageNix = false; # Determinate Nix owns the daemon.
    manageHomebrew = false; # Leave existing applications and formulae alone.
    desktopApps = false;
    developmentExtras = false;
  };
}
