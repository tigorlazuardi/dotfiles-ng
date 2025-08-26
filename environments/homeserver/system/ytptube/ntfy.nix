{
  config,
  pkgs,
  ...
}:
{
  services.ntfy-sh.middlewares = [
    {
      topic = "ytptube-raw";
      command = ''${
        pkgs.writers.writeJS "ytptube-raw-handler.mjs" { } ''
          const payload = process.argv[2];
          const token = process.env.NTFY_USER_BASE64;
          console.log(payload);

          const parsed = JSON.parse(payload);
          const attachmentUrl = parsed.attachment?.url;
          let rawData;
          if (attachmentUrl) {
            const res = await fetch(attachmentUrl);
            rawData = await res.text();
          } else {
            rawData = parsed.message;
          }
          const { event, title, data, message } = JSON.parse(rawData);

          const body = {
            topic: "ytptube",
            title,
            message,
            attach: data.extras.thumbnail,
            priority: 3,
            icon: "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube-dl.png",
            click: "https://ytptube.tigor.web.id",
            tags: [data.folder],
            actions: [
              {
                action: "view",
                label: "Source",
                url: data.url,
              },
            ],
          };

          fetch("https://${config.services.ntfy-sh.domain}", {
            method: "POST",
            headers: {
              Authorization: `Basic ''${token}`,
            },
            body: JSON.stringify(body),
          })
            .then((_) => {
              console.log(
                JSON.stringify({
                  message: `Notification sent to topic ytptube on event ''${event}`,
                  body,
                }),
              );
            })
            .catch((err) => {
              console.error(
                JSON.stringify({
                  message: `Failed to send notification to topic ytptube on event ''${event}`,
                  error: err.message,
                  body,
                }),
              );
            });
        ''
      } "$raw"'';
    }
  ];
}
