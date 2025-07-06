{
  lib,
  pkgs,
  ...
}:
let
  plugins = {
    zj-quit = pkgs.fetchurl {
      url = "https://github.com/cristiand391/zj-quit/releases/download/0.3.1/zj-quit.wasm";
      hash = "sha256-JSYnGGN2SLNComhMg4P814dV3TV6jRvTv9fts9oTf5Q=";
    };
    zj-status = pkgs.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v0.19.0/zjstatus.wasm";
      hash = "sha256-xU2CA+okW8gg9l25mLWgaQFNnzoa8Z6KH0tenmiUvhM=";
    };
  };
in
{
  config = {
    programs.zellij.enable = true;

    systemd.user = {
      services.zellij-cleanup = {
        Service = {
          Description = "Zellij cleanup killed sessions";
          ExecStart = "${pkgs.zellij}/bin/zellij delete-all-sessions --yes";
        };
      };
      timers.zellij-cleanup = {
        Unit = {
          Description = "Zellij cleanup killed sessions";
        };
        Timer = {
          OnCalendar = "*-*-* 4:00:00";
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };

    # The lib.mkOrder is used to ensure zellij is
    # autoloaded first after zshenv.
    programs.zsh.initContent =
      lib.mkOrder 50
        # sh
        ''
          if [[ ! -z "$SSH_CLIENT" ]]; then
            if [[ -z "$ZELLIJ" ]]; then
                active_sessions=$(zellij list-sessions --no-formatting --reverse | grep -v "EXITED")
                if [[ ! -n "$active_sessions" ]]; then
                    # No active sessions.
                    zellij --new-session-with-layout base
                else 
                    selected=$(echo "$active_sessions" | ${pkgs.skim}/bin/sk | awk '{print $1}')
                    if [[ -n "''${selected// /}" ]]; then
                        zellij attach "$selected"
                    else
                        zellij --new-session-with-layout base
                    fi
                fi
                exit
            fi
          fi
        '';

    programs.fish.shellInit =
      lib.mkOrder 10
        # fish
        ''
          status is-interactive; and begin
            if test -n "$SSH_CLIENT"; and test -z "$ZELLIJ"
              set -l active_sessions (zellij list-sessions --no-formatting --reverse | grep -v "EXITED")
              if test (count $active_sessions) -eq 0
                zellij --new-session-with-layout base
              else
                set -l selected (printf %s\n $active_sessions | ${pkgs.skim}/bin/sk | awk '{print $1}')
                if test -n "$selected"
                  zellij attach "$selected"
                else
                  zellij --new-session-with-layout base
                end
              end
              kill $fish_pid
            end
          end
        '';

    home.file.".config/zellij/config.kdl".text =
      let
        mod = "ctrl b";
      in
      # kdl
      ''
        theme "catppuccin-mocha";

        show_startup_tips false

        plugins {
            zj-quit location="file:${plugins.zj-quit}";
        }

        session_serialization false

        keybinds clear-defaults=true {
          shared_except "locked" {
              bind "Ctrl q" {
                  LaunchOrFocusPlugin "zj-quit" {
                      floating true
                  };
              }
          }

          normal {
              bind "${mod}" { SwitchToMode "tmux"; }
          }

          locked {
              bind "${mod}" { SwitchToMode "normal"; }
          }

          tmux {
              // Switching modes
              bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
              bind "w" { SwitchToMode "Resize"; }
              bind "e" { SwitchToMode "Scroll"; }
              bind "S" { SwitchToMode "Session"; }
              bind "r" { SwitchToMode "RenamePane"; PaneNameInput 0; }
              bind "R" { SwitchToMode "RenameTab"; TabNameInput 0; }
              bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "\\" { SwitchToMode "locked"; }


              // Pane management
              bind "Enter" { NewPane "Right"; SwitchToMode "Normal"; };
              bind "Backspace" { NewPane "Down"; SwitchToMode "Normal"; };
              bind "q" { CloseFocus; SwitchToMode "Normal"; }
              bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
              bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
              bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
              bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
              bind "H" { MovePane "Left"; SwitchToMode "Normal"; }
              bind "J" { MovePane "Down"; SwitchToMode "Normal"; }
              bind "K" { MovePane "Up"; SwitchToMode "Normal"; }
              bind "L" { MovePane "Right"; SwitchToMode "Normal"; }
              bind "Space" { ToggleFocusFullscreen; SwitchToMode "Normal"; }

              // Tab management
              bind "t" { NewTab; SwitchToMode "Normal"; }
              bind "x" { CloseTab; SwitchToMode "Normal"; }
              bind "1" { GoToTab 1; SwitchToMode "Normal"; }
              bind "2" { GoToTab 2; SwitchToMode "Normal"; }
              bind "3" { GoToTab 3; SwitchToMode "Normal"; }
              bind "4" { GoToTab 4; SwitchToMode "Normal"; }
              bind "5" { GoToTab 5; SwitchToMode "Normal"; }
              bind "6" { GoToTab 6; SwitchToMode "Normal"; }
              bind "7" { GoToTab 7; SwitchToMode "Normal"; }
              bind "8" { GoToTab 8; SwitchToMode "Normal"; }
              bind "9" { GoToTab 9; SwitchToMode "Normal"; }

              // Session management
              bind "s" {
                  LaunchOrFocusPlugin "session-manager" {
                      floating true
                      move_to_focused_tab true
                  };
                  SwitchToMode "Normal";
              }
          }

          resize {
              bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
              bind "h" "Left" { Resize "Increase Left"; }
              bind "j" "Down" { Resize "Increase Down"; }
              bind "k" "Up" { Resize "Increase Up"; }
              bind "l" "Right" { Resize "Increase Right"; }
              bind "H" { Resize "Decrease Left"; }
              bind "J" { Resize "Decrease Down"; }
              bind "K" { Resize "Decrease Up"; }
              bind "L" { Resize "Decrease Right"; }
              bind "=" "+" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
          }

          search {
              bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "Ctrl s" { SwitchToMode "Normal"; }
              bind "Ctrl c" "Esc" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
              bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "n" { Search "down"; }
              bind "p" { Search "up"; }
              bind "c" { SearchToggleOption "CaseSensitivity"; }
              bind "w" { SearchToggleOption "Wrap"; }
              bind "o" { SearchToggleOption "WholeWord"; }
          }

          entersearch {
              bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
              bind "Enter" { SwitchToMode "Search"; }
          }

          scroll {
              bind "Esc" { SwitchToMode "Normal"; }
              bind "e" { EditScrollback; SwitchToMode "Normal"; }
              bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
              bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
          }

          session {
              bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
              bind "d" { Detach; }
              bind "S" {
                  LaunchOrFocusPlugin "session-manager" {
                      floating true
                      move_to_focused_tab true
                  };
                  SwitchToMode "Normal"
              }
              bind "c" {
                  LaunchOrFocusPlugin "configuration" {
                      floating true
                      move_to_focused_tab true
                  };
                  SwitchToMode "Normal"
              }
          }

          renametab {
              bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
              // bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
          }
          renamepane {
              bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
              // bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
          }

          // Unused modes is only given escape keys to return to normal mode.
          pane {
              bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
          }

          move {
              bind "Ctrl c" "Esc" { SwitchToMode "Normal"; }
          }
        }
      '';

    home.file.".config/zellij/layouts/default.kdl".source = pkgs.callPackage ./zjstatus.nix { };
    home.file.".config/zellij/layouts/base.kdl".source = pkgs.callPackage ./zjstatus.nix { };
  };
}
