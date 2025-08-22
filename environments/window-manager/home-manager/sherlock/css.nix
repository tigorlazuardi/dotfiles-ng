{ config, ... }:
{
  imports = [
    ../wallust
  ];

  xdg.configFile."wallust/templates/sherlock.css".text = # css
    ''
      :root {
        --background: {{ background }};
        --foreground: {{ foreground }};
        --text: {{ foreground }};
        --border: {{ background | lighten(0.5) }};

        --tag-background: {{ background }};
        --tag-color: {{ cursor }};
        --error: {{ color3 }};
        --warning: {{ color1 }};
        --success: {{ color4 }};

        --weather-clear: linear-gradient(45deg, #87b2e0 0%, #ced9e5 50%);
        --weather-few-clouds: linear-gradient(45deg, #a1a1a1 0%, #87b2e0 100%);
        --weather-many-clouds: linear-gradient(45deg, #b2b2b2 0%, #c8c8c8 100%);
        --weather-mist: linear-gradient(45deg, #878787 0%, #d1d1c7 100%);
        --weather-showers: linear-gradient(45deg, #73848c 0%, #374b54 100%);
        --weather-freezing-scattered-rain-storm: linear-gradient(
          45deg,
          #1a1c1f 0%,
          #242b35 100%
        );
        --weather-freezing-scattered-rain: linear-gradient(
          45deg,
          #73848c 0%,
          #242b35 100%
        );
        --weather-snow-scattered-day: linear-gradient(
          45deg,
          #73848c 0%,
          #242b35 100%
        );
        --weather-storm: linear-gradient(45deg, #1a1c1f 0%, #242b35 100%);
        --weather-snow-storm: linear-gradient(45deg, #1a1c1f 0%, #242b35 100%);
        --weather-snow-scattered-storm: linear-gradient(
          45deg,
          #1a1c1f 0%,
          #242b35 100%
        );
        --weather-showers-scattered: linear-gradient(45deg, #73848c 0%, #374b54 100%);

        --weather-none-available: hsl(0, 0%, 50%);
        /* Neutral placeholder gray */
      }

      /*
      --warning: hsl(36, 89%, 52%);
      --error: hsl(0, 89%, 59%);
      --success: hsl(102, 36%, 53%;
      */

      overshoot *,
      undershoot *,
      overshoot.top,
      overshoot.right,
      overshoot.bottom,
      overshoot.left undershoot.top,
      undershoot.right,
      undershoot.bottom,
      undershoot.left,
      .scroll-window > *,
      overshoot:backdrop {
        background: none;
        border: none;
        background-color: transparent;
      }

      * {
        all: unset;
        padding: 0px;
        margin: 0px;
        -gtk-secondary-caret-color: var(--background);
        outline-width: 0px;
        outline-offset: -3px;
        outline-style: dashed;
        line-height: 1;
        font-family: "Cantarell";
      }

      label {
        color: var(--text);
      }

      #overlay spinner {
        color: var(--text);
      }

      row:selected,
      #overlay * {
        background: transparent;
      }

      .notifications {
        background: transparent;
      }

      scrolledwindow > viewport,
      scrolledwindow > viewport > *,
      listview,
      gridview,
      window {
        background: alpha(var(--background), 0.5);
      }

      #backdrop {
        background: black;
      }

      window:not(#backdrop) {
        color: var(--text);
        border-radius: 5px;
        border: 2px solid var(--border);
      }

      /* SEARCH PAGE */
      #search-bar {
        outline: none;
        border: none;
        background: alpha(hsl(from var(--background) h s l / 100%), 0.7);
        min-height: 40px;
        color: var(--text);
        font-size: 15px;
        padding-left: 20px;
      }

      #search-bar-holder {
        border-bottom: 2px solid var(--border);
        padding: 5px 10px 4px 10px;
      }

      #search-icon-holder image {
        transition: 0.1s ease;
      }

      #search-icon-holder.search image:nth-child(1) {
        transition-delay: 0.05s;
        opacity: 1;
      }

      #search-icon-holder.search image:nth-child(2) {
        transform: rotate(-180deg);
        opacity: 0;
      }

      #search-icon-holder.back image:nth-child(1) {
        opacity: 0;
      }

      #search-icon-holder.back image:nth-child(2) {
        transition-delay: 0.05s;
        opacity: 1;
      }

      #search-icon {
        margin-left: 10px;
      }

      #search-bar:focus {
        outline: none;
      }

      #search-bar placeholder {
        background: transparent;
        background-color: transparent;
        color: hsl(from var(--text) h s l / 70%);
        font-weight: 500;
      }

      #category-type {
        font-size: 13px;
        font-weight: bold;
        color: var(--text);
        opacity: 0.3;
        padding: 10px 20px 0px 20px;
      }

      .scrolled-window {
        padding: 10px 10px 5px 10px;
        min-width: var(--width) * 0.8;
      }

      scrollbar {
        transform: translate(8px, 0px);
        border: none;
        background: none;
      }

      scrollbar slider {
        background: hsl(from var(--text) h s l / 10%);
        border: none;
      }

      image {
        color: white;
      }

      .tile {
        outline: none;
        min-height: 50px;
        padding: 0px 10px;
        margin-bottom: 5px;
        border: 1px solid transparent;
        border-radius: 4px;
      }

      .tile:hover *,
      .tile:hover {
        background: transparent;
      }

      .tile.animate {
        transform: translateY(20px);
        opacity: 0;
        animation: fadeInUp 0.2s ease-out forwards;
      }

      row:nth-child(1) .tile.animate {
        animation-delay: 0.05s;
      }

      row:nth-child(2) .tile.animate {
        animation-delay: 0.1s;
      }

      row:nth-child(3) .tile.animate {
        animation-delay: 0.15s;
      }

      row:nth-child(4) .tile.animate {
        animation-delay: 0.2s;
      }

      row:nth-child(5) .tile.animate {
        animation-delay: 0.25s;
      }

      row:nth-child(6) .tile.animate {
        animation-delay: 0.3s;
      }

      row:nth-child(7) .tile.animate {
        animation-delay: 0.35s;
      }

      row:nth-child(8) .tile.animate {
        animation-delay: 0.4s;
      }

      row:nth-child(9) .tile.animate {
        animation-delay: 0.45s;
      }

      row:nth-child(10) .tile.animate {
        animation-delay: 0.5s;
      }

      @keyframes fadeInUp {
        from {
          letter-spacing: 1px;
          opacity: 0;
          transform: translateY(20px);
        }

        to {
          letter-spacing: 0px;
          opacity: 1;
          transform: translate(0px);
        }
      }

      .tile #title {
        font-size: 1.15rem;
        color: var(--text);
      }

      .tile #icon {
        margin: 0px;
        padding: 0px;
      }

      row:selected .tile {
        background: alpha(hsl(from var(--foreground) h s l / 100%), 0.2);
        background-color: alpha(hsl(from var(--foreground) h s l / 100%), 0.2);
      }

      row:selected .tile.multi-active,
      .tile.multi-active {
        background: alpha(hsl(from var(--foreground) h s l / 100%), 0.2);
        background-color: alpha(hsl(from var(--foreground) h s l / 100%), 0.2);
        border: 1px solid hsl(from var(--text) h s l / 20%);
      }

      .tile:selected .tag,
      .tag {
        font-size: 0.75rem;
        border-radius: 3px;
        padding: 2px 8px;
        color: var(--tag-color);
        box-shadow: 0px 0px 10px 0px rgba(2, 2, 2, 0.4);
        border: 1px solid hsl(from var(--text) h s l / 10%);
        margin-left: 7px;
      }

      .tile:selected .tag-start,
      .tag-start {
        background: hsl(from var(--tag-background) h s l / 70%);
      }

      .tile:selected .tag-end,
      .tag-end {
        background: var(--success);
        color: var(--text);
      }

      .tile:focus {
        outline: none;
      }

      #launcher-type {
        font-size: 0.75rem;
        color: hsl(from var(--text) h s l / 50%);
        margin-left: 0px;
      }

      #color-icon-holder {
        border-radius: 50px;
      }

      /*SHORTCUT*/
      #shortcut-holder {
        margin-right: 25px;
        padding: 5px 10px;
        background: hsl(from {{cursor}} h s l / 50%);
        border-radius: 5px;
        border: 1px solid hsl(from var(--text) h s l / 10%);
        box-shadow: 0px 0px 6px 0px rgba(15, 15, 15, 1);
      }

      .tile:selected #shortcut-holder {
        background: alpha(hsl(from var(--background) h s l / 50%),0.2);
        background-color: alpha(hsl(from var(--background) h s l / 50%), 0.2);
        color: hsl(from var(--text) h s l / 50%);
        box-shadow: 0px 0px 6px 0px rgba(22, 22, 22, 1);
      }

      #shortcut,
      #shortcut-modkey {
        background: hsl(from {{cursor}} h s l / 0%);
        background-color: hsl(from var(--background) h s l / 0%);
        font-size: 0.75rem;
        font-weight: bold;
        color: var(--text);
      }

      #shortcut-modkey {
        font-size: 13px;
      }

      /*CALCULATOR*/
      .calc-tile {
        padding: 10px 10px 20px 10px;
        border-radius: 5px;
      }

      #calc-tile-quation {
        font-size: 10px;
        color: gray;
      }

      #calc-tile-result {
        font-size: 25px;
        color: gray;
      }

      /*EVENT TILE*/
      .tile.tile.event-tile {
        padding: 5px 10px;
      }

      .tile.event-tile #title-label {
        padding: 2px 0px 7px 5px;
        text-transform: capitalize;
      }

      .tile.event-tile #time-label {
        font-size: 3rem;
      }

      #end-time-label {
        color: gray;
      }

      /* BULK TEXT TILE */
      .bulk-text {
        padding-bottom: 10px;
        min-height: 50px;
      }

      #bulk-text-title {
        margin-left: 10px;
        padding: 10px 0px;
        font-size: 10px;
        color: gray;
      }

      #bulk-text-content-title {
        font-size: 17px;
        font-weight: bold;
        color: var(--text);
        min-height: 20px;
      }

      #bulk-text-content-body {
        font-size: 14px;
        color: var(--text);
        line-height: 1.4;
        min-height: 20px;
      }

      /* MPRIS TILE*/
      #mpris-icon-holder {
        border-radius: 5px;
      }

      /*Animation for replacing album covers*/
      .image-replace-overlay #album-cover {
        opacity: 1;
        animation: ease-opacity 0.5s forwards;
      }

      /* EMOJI */
      gridview child {
        padding: 5px;
        background: transparent;
      }

      gridview child box {
        background: var(--foreground);
        border-radius: 5px;
        border: 1px solid transparent;
      }

      gridview child:selected box {
        border: 1px solid var(--tag-color);
      }

      /* NEXT PAGE */
      .next_tile {
        color: var(--text);
        background: var(--background);
      }

      .next_tile #content-body {
        background: var(--background);
        padding: 10px;
        color: var(--text);
      }

      .raw_text,
      .next_tile #content-body {
        font-family: "Fira Code", monospace;
        font-feature-settings: "kern" off;
        font-kerning: None;
      }

      /*Error*/
      .error-tile #scroll-window {
        padding: 10px;
        min-height: 50px;
      }

      .error-tile {
        border-radius: 4px;
        padding: 5px 10px 10px 10px;
        color: white;
        border: 1px solid transparent;
        margin-bottom: 10px;
      }

      .error-tile * {
        background: transparent;
      }

      .error {
        border: 1px solid hsl(from var(--error) h s l / 50%);
        background: hsl(from var(--error) h s l / 10%);
      }

      .warning {
        border: 1px solid hsl(from var(--warning) h s l / 50%);
        background: hsl(from var(--warning) h s l / 10%);
      }

      .error-tile #title {
        padding: 10px;
        font-size: 10px;
        color: gray;
      }

      .error-tile #content-title {
        margin-left: 10px;
        font-size: 16px;
        font-weight: bold;
        color: var(--text);
      }

      .error-tile #content-body {
        margin-left: 10px;
        font-size: 14px;
        color: var(--text);
        line-height: 1.4;
        color: gray;
      }

      /* STATUS BAR */
      .status-bar {
        background: alpha(hsl(from var(--foreground) h s l / 20%), 0.1);
        border-top: 1px solid var(--border);
        padding: 4px 10px 4px 20px;
      }

      .status-bar label {
        color: hsl(from var(--text) h s l / 50%);
      }

      .status-bar #shortcut-key,
      .status-bar #shortcut-modifier {
        background: alpha(var(--foreground), 0.2);
        color: var(--text);
        margin: 2px;
        padding: 1px 5px;
        border-radius: 3px;
        font-size: 1rem;
      }

      .status-bar #shortcut-description {
        font-size: 13px;
        margin-right: 10px;
      }

      .spinner-disappear {
        animation: vanish-rotate 0.3s ease forwards;
      }

      .spinner-appear {
        animation: ease-opacity 0.3s ease forwards;
        animation: rotate 0.3s linear infinite;
      }

      .inactive {
        opacity: 0;
        transition: 0.1s ease;
      }

      .active {
        opacity: 1;
        transition: 0.1s ease;
      }

      /* CONTEXT MENU */
      #context-menu {
        min-width: 50px;
        padding: 5px;
        margin: 4px;
        background: var(--background);
        border: 1px solid var(--border);
        border-radius: 5px;
        box-shadow: unset;
      }

      #context-menu row {
        color: hsl(from var(--text) h s l / 80%);
        transition: 0.1s ease;
        padding: 10px 20px;
        border-radius: 5px;
      }

      #context-menu label {
        color: hsl(from var(--text) h s l / 80%);
        font-size: 13px;
      }

      #context-menu row:selected {
        background: alpha(var(--foreground), 0.2);
      }

      /* WEATHER TILE */
      .weather-tile {
        padding: 0px 20px 0px 10px;
        background: darkgray;
        /* margin-bottom: 10px; */
      }

      .tile.weather-tile #content-holder {
        opacity: 0;
      }

      .tile.weather-tile.weather-animate #content-holder {
        animation: ease-opacity 0.3s forwards;
        transition: background 0.3s ease;
        opacity: 1;
      }

      .tile.weather-tile.weather-no-animate #content-holder {
        opacity: 1;
      }

      .tile.weather-tile #location {
        margin-left: 5px;
        padding: 10px 0px;
        font-size: 10px;
      }

      .tile.weather-tile #temperature {
        font-size: 30px;
      }

      .tile.weather-tile #content-holder {
        margin-bottom: 15px;
      }

      /*WEATHER CLASSES*/
      /* Weather Types */
      .tile.weather-tile.weather-clear {
        background: var(--weather-clear);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-few-clouds {
        background: var(--weather-few-clouds);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-many-clouds {
        background: var(--weather-many-clouds);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-mist {
        background: var(--weather-mist);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-showers {
        background: var(--weather-showers);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-freezing-scattered-rain-storm {
        background: var(--weather-freezing-scattered-rain-storm);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-freezing-scattered-rain {
        background: var(--weather-freezing-scattered-rain);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-snow-scattered-day {
        background: var(--weather-snow-scattered-day);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-storm {
        background: var(--weather-storm);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-snow-storm {
        background: var(--weather-snow-storm);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-snow-scattered-storm {
        background: var(--weather-snow-scattered-storm);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-showers-scattered {
        background: var(--weather-showers-scattered);
        background-clip: padding-box;
      }

      .tile.weather-tile.weather-none-available {
        background: var(--weather-none-available);
        background-clip: padding-box;
      }

      /* TIMER TILE */
      .tile.timer-tile {
        padding: 10px 10px 10px 15px;
        background: transparent;
      }

      .tile.timer-tile.normal #timer-count {
        font-size: 2.5em;
        padding: 1.25em;
      }

      .tile.timer-tile.minimal #timer-count {
        font-size: 1.5em;
      }

      #timer-title {
        color: hsl(from var(--text) h s l / 70%);
        font-size: 11px;
      }

      #timer-image {
        /* -gtk-icon-filter: brightness(10) saturate(100%) contrast(100%); /1* white *1/ */
        filter: brightness(10) saturate(100%) contrast(100%);
        /* black */
      }

      /* EMOJIES */
      .emoji-item {
        padding: 20px;
      }

      .emoji-item #emoji-name {
        font-size: 10px;
        color: hsl(from var(--text) h s l / 30%);
      }

      #context-menu.emoji row {
        padding: 3px;
      }

      #context-menu.emoji label {
        padding: 5px;
        border-radius: 3px;
      }

      #context-menu.emoji label.active {
        background: hsl(from var(--text) h s l / 10%);
      }

      /*ANIMATIONS*/
      @keyframes vanish-rotate {
        from {
          opacity: 1;
        }

        to {
          opacity: 0;
          transform: rotate(360deg);
        }
      }

      @keyframes rotate {
        from {
          transform: rotate(0deg);
          --start-rotation: 0deg;
        }

        to {
          transform: rotate(360deg);
          --start-rotation: 360deg;
        }
      }

      @keyframes ease-opacity {
        from {
          opacity: 0;
        }

        to {
          opacity: 1;
        }
      }

      @keyframes slide {
        from {
          transform: translate(0px, 0px);
        }

        to {
          transform: translate(-20px, 0px);
        }
      }

      @keyframes slide {
        from {
          transform: translate(0px, 0px);
        }

        to {
          transform: translate(-20px, 0px);
        }
      }
    '';

  programs.wallust.settings.templates.sherlock = {
    src = "sherlock.css";
    dst = "${config.xdg.configHome}/sherlock/main.css";
  };
}
