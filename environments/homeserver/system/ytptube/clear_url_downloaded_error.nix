{
  config,
  pkgs,
  ...
}:
{
  systemd = {
    services.podman-ytptube-clear-url-is-already-downloaded = {
      description = "Clear YTPTube 'URL is already downloaded' Errors";
      after = [ "podman-ytptube.service" ];
      requisite = [ "podman-ytptube.service" ];
      partOf = [ "podman-ytptube.service" ];
      serviceConfig.ExecStart = pkgs.writers.writeJS "ytptube-clear-url-is-already-downloaded" { } ''
        const baseUrl = "http://ytptube.lan";
        const historyResponse = await fetch(`''${baseUrl}/api/history`);
        const { history } = await historyResponse.json();

        const targetError = "URL is already downloaded";
        const itemsToClear = history.filter(
          (item) => item.msg && item.msg.includes(targetError),
        );
        if (itemsToClear.length === 0) {
          console.info("No history items with the target error to clear.");
          process.exit(0);
        }
        const ids = itemsToClear.map((item) => item._id);
        console.info("History items to clear found:", itemsToClear.length, "IDs:", ids);
        const deleteResponse = await fetch(`''${baseUrl}/api/history`, {
          method: "DELETE",
          body: JSON.stringify({ ids, where: "done" }),
        });
        if (!deleteResponse.ok) {
          console.error("Failed to delete history items:", await deleteResponse.text());
          process.exit(1);
        }
        console.info("Successfully cleared history items with the target error.");
      '';
    };
    timers.podman-ytptube-clear-url-is-already-downloaded = {
      description = "Scheduler for clearing YTPTube 'URL is already downloaded' errors";
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "hourly";
    };
  };
}
