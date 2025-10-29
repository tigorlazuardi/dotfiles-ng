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

        const now = Date.now();
        const filter = (item) => {
          let erred = item.error !== null;
          if (erred) return erred;
          if (item.is_archived) return false;
          if (item.status === "not_live") {
            const liveTime = new Date(item.live_in).getTime();
            return liveTime - now < 0; // live stream has started, but ytptube has not attempted download it yet.
          }
          return false;
        };

        const failedDownloads = history.filter(filter);
        if (failedDownloads.length === 0) {
          console.info("No failed downloads to retry.");
          process.exit(0);
        }
        const ids = failedDownloads.map((item) => item._id);
        console.info("Failed downloads found:", failedDownloads.length, "IDs:", ids);
        const deleteResponse = await fetch(`''${baseUrl}/api/history`, {
          method: "DELETE",
          body: JSON.stringify({ ids, where: "done" }),
        });
        if (!deleteResponse.ok) {
          console.error("Failed to delete history items:", await deleteResponse.text());
          process.exit(1);
        }
        let body = failedDownloads.map((item) => ({
          url: item.url,
          preset: item.preset,
          folder: item.folder,
          cookies: item.cookies,
          template: "${template}",
          cli: item.cli,
          auto_start: item.auto_start,
        }));
        body = body.filter((item) => !item.error.includes("HTTP Error 403: Forbidden")); // Filter out 403 errors. They will never succeed.
        if (body.length === 0) {
          console.error("No downloads to retry after filtering out 403 errors.");
          process.exit(0);
        }
        console.info("Retrying downloads...");
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
