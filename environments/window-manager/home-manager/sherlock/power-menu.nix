{ pkgs, ... }:
{
  programs.sherlock.launchers = [
    {
      name = "Power Menu";
      alias = "pm";
      type = "command";
      priority = 1;
      args = {
        commands = {
          "Lock Screen" = {
            search_string = "lock;screen";
            exec = "loginctl lock-session";
            icon =
              pkgs.writeText "lock.svg" # svg
                ''
                  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" stroke="#ffffff">
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <path d="M12 14.5V16.5M7 10.0288C7.47142 10 8.05259 10 8.8 10H15.2C15.9474 10 16.5286 10 17 10.0288M7 10.0288C6.41168 10.0647 5.99429 10.1455 5.63803 10.327C5.07354 10.6146 4.6146 11.0735 4.32698 11.638C4 12.2798 4 13.1198 4 14.8V16.2C4 17.8802 4 18.7202 4.32698 19.362C4.6146 19.9265 5.07354 20.3854 5.63803 20.673C6.27976 21 7.11984 21 8.8 21H15.2C16.8802 21 17.7202 21 18.362 20.673C18.9265 20.3854 19.3854 19.9265 19.673 19.362C20 18.7202 20 17.8802 20 16.2V14.8C20 13.1198 20 12.2798 19.673 11.638C19.3854 11.0735 18.9265 10.6146 18.362 10.327C18.0057 10.1455 17.5883 10.0647 17 10.0288M7 10.0288V8C7 5.23858 9.23858 3 12 3C14.7614 3 17 5.23858 17 8V10.0288" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
                    </g>
                  </svg>
                '';
          };
          Suspend = {
            search_string = "suspend;sleep";
            exec = "systemctl suspend";
            icon =
              pkgs.writeText "sleep.svg" # svg
                ''
                  <svg version="1.1" id="Uploaded to svgrepo.com" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 32 32" xml:space="preserve" fill="#ffffff" stroke="#ffffff">
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <style type="text/css">
                        .linesandangles_een {
                          fill: #ffffff;
                        }
                      </style>
                      <path class="linesandangles_een" d="M27.577,12.912c-1.401-5.23-6.164-8.884-11.58-8.884c-0.48,0-0.966,0.029-1.442,0.087 L14.004,5.85c1.146,1.037,1.963,2.37,2.361,3.854c1.142,4.261-1.396,8.657-5.657,9.798c-1.482,0.398-3.052,0.357-4.518-0.118 l-1.228,1.344c1.888,4.429,6.214,7.291,11.021,7.291h0.001c1.043,0,2.089-0.138,3.106-0.411c3.096-0.83,5.684-2.815,7.286-5.591 C27.981,19.242,28.407,16.008,27.577,12.912z M24.646,21.018c-1.336,2.313-3.492,3.968-6.072,4.659 c-0.849,0.228-1.72,0.343-2.589,0.343h-0.001c-3.312,0-6.35-1.631-8.191-4.282c1.15,0.101,2.313-0.002,3.433-0.303 c5.326-1.427,8.498-6.921,7.071-12.248c-0.301-1.125-0.794-2.178-1.453-3.123c4.155,0.353,7.707,3.282,8.802,7.365 C26.337,16.01,25.981,18.705,24.646,21.018z"></path>
                    </g>
                  </svg>
                '';
          };
          "Suspend then Hibernate" = {
            search_string = "suspend;hibernate;sleep";
            exec = "systemctl suspend-then-hibernate";
            icon =
              pkgs.writeText "sleep-filled.svg" # svg
                ''
                  <svg version="1.1" id="Uploaded to svgrepo.com" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 32 32" xml:space="preserve" fill="#ffffff" stroke="#ffffff">
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <style type="text/css">
                        .puchipuchi_een {
                          fill: #ffffff;
                        }
                      </style>
                      <path class="puchipuchi_een" d="M28.62,17.482c0.508-0.452,1.324-0.028,1.215,0.675C28.797,24.865,22.998,30,16,30 C8.268,30,2,23.732,2,16C2,8.985,7.16,3.175,13.891,2.158c0.688-0.104,1.096,0.698,0.651,1.195C12.963,5.119,12,7.445,12,10 c0,5.523,4.477,10,10,10C24.542,20,26.858,19.047,28.62,17.482z"></path>
                    </g>
                  </svg>
                '';
          };
          Hibernate = {
            search_string = "hibernate";
            exec = "systemctl hibernate";
            icon =
              pkgs.writeText "hibernate.svg" # svg
                ''
                  <svg height="200px" width="200px" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 24.393 24.393" xml:space="preserve" fill="#ffffff" stroke="#ffffff">
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <g>
                        <path style="fill:#ffffff;" d="M12.196,0C5.46,0,0,5.46,0,12.196s5.46,12.197,12.196,12.197s12.197-5.461,12.197-12.197 S18.932,0,12.196,0z M12.196,21.782c-5.295,0-9.586-4.291-9.586-9.586S6.901,2.61,12.196,2.61s9.586,4.291,9.586,9.586 S17.491,21.782,12.196,21.782z M14.1,7.436v9.519c0,1.051-0.852,1.904-1.904,1.904s-1.904-0.852-1.904-1.904V7.436 c0-1.051,0.852-1.904,1.904-1.904S14.1,6.385,14.1,7.436z"></path>
                      </g>
                    </g>
                  </svg>
                '';
          };
          Restart = {
            search_string = "restart;reboot";
            exec = "systemctl reboot";
            icon =
              pkgs.writeText "restart.svg" # svg
                ''
                  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" stroke="#ffffff">
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <path fill-rule="evenodd" clip-rule="evenodd" d="M12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22ZM15.9346 5.59158C16.217 5.70662 16.4017 5.98121 16.4017 6.28616V9.00067C16.4017 9.41489 16.0659 9.75067 15.6517 9.75067H13C12.6983 9.75067 12.4259 9.56984 12.3088 9.29174C12.1917 9.01364 12.2527 8.69245 12.4635 8.47659L13.225 7.69705C11.7795 7.25143 10.1467 7.61303 9.00097 8.78596C7.33301 10.4935 7.33301 13.269 9.00097 14.9765C10.6593 16.6742 13.3407 16.6742 14.999 14.9765C15.6769 14.2826 16.0805 13.4112 16.2069 12.5045C16.2651 12.0865 16.5972 11.7349 17.0192 11.7349C17.4246 11.7349 17.7609 12.0595 17.7217 12.463C17.5957 13.7606 17.0471 15.0265 16.072 16.0247C13.8252 18.3248 10.1748 18.3248 7.92796 16.0247C5.69068 13.7344 5.69068 10.0281 7.92796 7.7378C9.66551 5.95905 12.244 5.55465 14.3647 6.53037L15.1152 5.76208C15.3283 5.54393 15.6522 5.47653 15.9346 5.59158Z" fill="#ffffff"></path>
                    </g>
                  </svg>
                '';
          };
          "Power Off" = {
            search_string = "power;off;shutdown";
            exec = "systemctl poweroff";
            icon =
              pkgs.writeText "poweroff.svg" # svg
                ''
                  <svg fill="#ffffff" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" class="icon" stroke="#ffffff">
                    <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                    <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                    <g id="SVGRepo_iconCarrier">
                      <path d="M705.6 124.9a8 8 0 0 0-11.6 7.2v64.2c0 5.5 2.9 10.6 7.5 13.6a352.2 352.2 0 0 1 62.2 49.8c32.7 32.8 58.4 70.9 76.3 113.3a355 355 0 0 1 27.9 138.7c0 48.1-9.4 94.8-27.9 138.7a355.92 355.92 0 0 1-76.3 113.3 353.06 353.06 0 0 1-113.2 76.4c-43.8 18.6-90.5 28-138.5 28s-94.7-9.4-138.5-28a353.06 353.06 0 0 1-113.2-76.4A355.92 355.92 0 0 1 184 650.4a355 355 0 0 1-27.9-138.7c0-48.1 9.4-94.8 27.9-138.7 17.9-42.4 43.6-80.5 76.3-113.3 19-19 39.8-35.6 62.2-49.8 4.7-2.9 7.5-8.1 7.5-13.6V132c0-6-6.3-9.8-11.6-7.2C178.5 195.2 82 339.3 80 506.3 77.2 745.1 272.5 943.5 511.2 944c239 .5 432.8-193.3 432.8-432.4 0-169.2-97-315.7-238.4-386.7zM480 560h64c4.4 0 8-3.6 8-8V88c0-4.4-3.6-8-8-8h-64c-4.4 0-8 3.6-8 8v464c0 4.4 3.6 8 8 8z"></path>
                    </g>
                  </svg>
                '';
          };
        };
      };
    }
  ];
}
