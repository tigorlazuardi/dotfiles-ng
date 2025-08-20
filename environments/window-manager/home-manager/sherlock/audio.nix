{ pkgs, ... }:
# Icons are taken from https://www.svgrepo.com
let
  speakerIcon =
    pkgs.writeText "speaker.svg" # svg
      ''
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <path d="M12 6.25C11.3096 6.25 10.75 6.80964 10.75 7.5C10.75 8.19036 11.3096 8.75 12 8.75C12.6904 8.75 13.25 8.19036 13.25 7.5C13.25 6.80964 12.6904 6.25 12 6.25Z" fill="#ffffff"></path>
            <path d="M9.75 15.5C9.75 14.2574 10.7574 13.25 12 13.25C13.2426 13.25 14.25 14.2574 14.25 15.5C14.25 16.7426 13.2426 17.75 12 17.75C10.7574 17.75 9.75 16.7426 9.75 15.5Z" fill="#ffffff"></path>
            <path fill-rule="evenodd" clip-rule="evenodd" d="M4 10C4 6.22876 4 4.34315 5.17157 3.17157C6.34315 2 8.22876 2 12 2C15.7712 2 17.6569 2 18.8284 3.17157C20 4.34315 20 6.22876 20 10V14C20 17.7712 20 19.6569 18.8284 20.8284C17.6569 22 15.7712 22 12 22C8.22876 22 6.34315 22 5.17157 20.8284C4 19.6569 4 17.7712 4 14V10ZM9.25 7.5C9.25 5.98122 10.4812 4.75 12 4.75C13.5188 4.75 14.75 5.98122 14.75 7.5C14.75 9.01878 13.5188 10.25 12 10.25C10.4812 10.25 9.25 9.01878 9.25 7.5ZM12 11.75C9.92893 11.75 8.25 13.4289 8.25 15.5C8.25 17.5711 9.92893 19.25 12 19.25C14.0711 19.25 15.75 17.5711 15.75 15.5C15.75 13.4289 14.0711 11.75 12 11.75Z" fill="#ffffff"></path>
          </g>
        </svg>
      '';
  headphoneIcon =
    pkgs.writeText "headphone.svg" # svg
      ''
        <svg height="200px" width="200px" version="1.1" id="_x32_" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512" xml:space="preserve" fill="#000000">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <style type="text/css">
              .st0 {
                fill: #ffffff;
              }
            </style>
            <g>
              <path class="st0" d="M175.898,335.919c-3.812-25.66-27.679-43.357-53.33-39.546c-25.659,3.778-43.374,27.671-39.57,53.322 l18.12,122.236c3.804,25.65,27.671,43.365,53.33,39.554c25.651-3.795,43.357-27.662,39.562-53.33L175.898,335.919z"></path>
              <path class="st0" d="M389.438,296.373c-25.651-3.811-49.518,13.886-53.33,39.546l-18.121,122.236 c-3.786,25.667,13.911,49.535,39.571,53.33c25.65,3.812,49.518-13.903,53.33-39.554l18.12-122.236 C432.811,324.044,415.088,300.151,389.438,296.373z"></path>
              <path class="st0" d="M506.813,166.683l-11.106-21.231c-22.6-43.187-56.364-79.478-97.625-105.07 C356.864,14.799,307.997-0.009,256.003,0C204-0.009,155.132,14.799,113.914,40.382c-41.26,25.592-75.025,61.883-97.616,105.07 L5.192,166.683c-4.301,8.224-1.14,18.391,7.099,22.701l7.649,3.99c-7.952,24.315-12.322,50.262-12.322,77.247 c0.042,31.753,7.353,62.948,15.594,90.551c8.231,27.476,17.57,51.707,21.965,67.402l35.683-10.074 c-5.29-18.593-14.384-42.004-22.152-67.959c-7.767-25.87-14.055-53.98-14.004-79.919c0-20.791,3.034-40.838,8.621-59.803 l1.436,0.777c8.24,4.285,18.391,1.116,22.692-7.116l11.105-21.239c15.788-30.198,39.512-55.679,68.332-73.538 c28.828-17.859,62.567-28.136,99.112-28.144c36.536,0.008,70.284,10.286,99.112,28.144c28.813,17.858,52.536,43.34,68.324,73.538 l11.106,21.239c4.302,8.231,14.461,11.4,22.693,7.116l1.437-0.777c5.586,18.965,8.628,39.012,8.628,59.803 c0.042,25.938-6.237,54.049-14.012,79.919c-7.759,25.955-16.861,49.366-22.152,67.959l35.683,10.074 c4.395-15.695,13.734-39.926,21.966-67.402c8.24-27.602,15.559-58.798,15.592-90.551c0-26.986-4.37-52.932-12.322-77.247 l7.649-3.99C507.945,185.074,511.107,174.907,506.813,166.683z"></path>
            </g>
          </g>
        </svg>
      '';
  monitorIcon =
    pkgs.writeText "monitor.svg" # svg
      ''
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
          <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
          <g id="SVGRepo_iconCarrier">
            <path d="M9 18V21M15 18V21M7 21H17M3 12H21M12 15H12.01M6.2 18H17.8C18.9201 18 19.4802 18 19.908 17.782C20.2843 17.5903 20.5903 17.2843 20.782 16.908C21 16.4802 21 15.9201 21 14.8V6.2C21 5.0799 21 4.51984 20.782 4.09202C20.5903 3.71569 20.2843 3.40973 19.908 3.21799C19.4802 3 18.9201 3 17.8 3H6.2C5.0799 3 4.51984 3 4.09202 3.21799C3.71569 3.40973 3.40973 3.71569 3.21799 4.09202C3 4.51984 3 5.07989 3 6.2V14.8C3 15.9201 3 16.4802 3.21799 16.908C3.40973 17.2843 3.71569 17.5903 4.09202 17.782C4.51984 18 5.07989 18 6.2 18Z" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
          </g>
        </svg>
      '';
in
{
  home.packages = [
    pkgs.pulseaudio
    (pkgs.writers.writeJSBin "sherlock-select-audio" { } ''
      import { spawnSync } from "node:child_process";

      const output = spawnSync("pactl", ["--format=json", "list", "sinks"]);
      if (output.error) {
        console.error(
          "error running command pactl --format=json list sinks:",
          output.error,
        );
        process.exit(1);
      }
      const audioList = JSON.parse(output.stdout.toString());
      const known = {
        "CX31993 384Khz HIFI AUDIO Analog Stereo": {
          icon: "${headphoneIcon}",
          alias: "Headphone",
          score: 5,
        },
        "Starship/Matisse HD Audio Controller Analog Stereo": {
          icon: "${speakerIcon}",
          alias: "Speaker",
          score: 3,
        },
      };
      const elements = audioList.map((audio) => {
        const out = {
          title: audio.description,
          description: `''${audio.properties["alsa.card_name"]} • ''${audio.name}`,
          field: "exec",
          hidden: {
            exec: `pactl set-default-sink ''${audio.name}`,
          },
        };
        const metadata = known[audio.description];
        if (!metadata) {
          if (audio.description.includes("HDMI")) {
            out.icon = "${monitorIcon}";
          } else {
            out.icon = "${speakerIcon}";
          }
          out.score = 0;
        } else {
          out.icon = metadata.icon;
          out.title = `''${metadata.alias} - ''${out.title}`;
          out.score = metadata.score;
        }
        return out;
      });
      elements.sort((a, b) => b.score - a.score); // Bigger score comes first.
      const result = spawnSync("sherlock", [], {
        input: JSON.stringify({ elements }),
      });
      if (result.error) {
        console.error("failed to run sherlock", result.error);
        process.exit(1);
      }
      const cmd = result.stdout.toString().trim();
      if (cmd === "") process.exit(0);
      spawnSync("bash", ["-c", cmd]);
    '')
  ];
}
