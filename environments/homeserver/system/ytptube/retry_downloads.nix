{
  config,
  pkgs,
  ...
}:
let
  template = config.virtualisation.oci-containers.containers.ytptube.environment.YTP_OUTPUT_TEMPLATE;
in
{
  systemd = {
    services.podman-ytptube-retry-downloads = {
      description = "Retry Failed YTPTube Downloads";
      after = [ "podman-ytptube.service" ];
      requisite = [ "podman-ytptube.service" ];
      partOf = [ "podman-ytptube.service" ];
      serviceConfig.ExecStart = pkgs.writers.writeJS "ytptube-retry-downloads" { } ''
        const baseUrl = "http://ytptube.lan";
        const historyResponse = await fetch(`''${baseUrl}/api/history`);
        const { history } = await historyResponse.json();

        const failedDownloads = history.filter((item) => item.error !== null);
        if (failedDownloads.length === 0) {
          console.log("No failed downloads to retry.");
          process.exit(0);
        }
        const ids = failedDownloads.map((item) => item._id);
        console.log("Failed downloads found:", failedDownloads.length, "IDs:", ids);
        const deleteResponse = await fetch(`''${baseUrl}/api/history`, {
          method: "DELETE",
          body: JSON.stringify({ ids, where: "done" }),
        });
        if (!deleteResponse.ok) {
          console.error("Failed to delete history items:", await deleteResponse.text());
          process.exit(1);
        }
        const body = failedDownloads.map((item) => ({
          url: item.url,
          preset: item.preset,
          folder: item.folder,
          cookies: item.cookies,
          template: "${template}",
          cli: item.cli,
          auto_start: item.auto_start,
        }));
        console.log("Retrying downloads...");
        console.table(body, ["url", "preset", "folder", "template", "cli"]);
        const response = await fetch(`''${baseUrl}/api/history`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });
        if (!response.ok) {
          console.error("Failed to retry downloads:", await response.text());
          process.exit(1);
        }
      '';
    };
    timers.podman-ytptube-retry-downloads = {
      description = "Scheduler for retrying failed YTPTube downloads";
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "hourly";
    };
  };
}
