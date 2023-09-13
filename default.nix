{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:

let
  sidebar = pkgs.tmuxPlugins.mkTmuxPlugin rec {
    pluginName = "sidebar";
    version = src.rev;
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-sidebar";
      rev = "a41d72c019093fd6a1216b044e111dd300684f1a";
      sha256 = "sha256-5+ISvoXXYDDfzSoPBO6v6Wt7IWsRVb9DcPgnO02rYd4=";
    };
  };

  vim-tmux-navigator = pkgs.tmuxPlugins.mkTmuxPlugin rec {
    pluginName = "vim-tmux-navigator";
    rtpFilePath = "vim-tmux-navigator.tmux";
    version = src.rev;
    src = pkgs.fetchFromGitHub {
      owner = "christoomey";
      repo = "vim-tmux-navigator";
      rev = "addb64a772cb4a3ae1f1363583012b2cada2cd66";
      sha256 = "sha256-iWY7SJUe82gvVeBSb6O9eJwlOWrU3j2pFICPTzWT2m4=";
    };
  };

  tmux-gruvbox = pkgs.tmuxPlugins.mkTmuxPlugin rec {
    pluginName = "tmux-gruvbox";
    rtpFilePath = "gruvbox-tpm.tmux";
    version = src.rev;
    src = pkgs.fetchFromGitHub {
      owner = "egel";
      repo = "tmux-gruvbox";
      rev = "3f9e38d7243179730b419b5bfafb4e22b0a969ad";
      sha256 = "sha256-jvGCrV94vJroembKZLmvGO8NknV1Hbgz2IuNmc/BE9A=";
    };
  };

  tmux-yank = pkgs.tmuxPlugins.mkTmuxPlugin rec {
    pluginName = "tmux-yank";
    rtpFilePath = "yank.tmux";
    version = src.rev;
    src = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tmux-yank";
      rev = "acfd36e4fcba99f8310a7dfb432111c242fe7392";
      sha256 = "sha256-/5HPaoOx2U2d8lZZJo5dKmemu6hKgHJYq23hxkddXpA=";
    };
  };

  tmux = (plugins:
    pkgs.stdenv.mkDerivation rec {

      inherit plugins;
      name = "tmux";
      srcs = ./.;
      nativeBuildInputs = with pkgs; [ makeWrapper ];
      buildInputs = [ pkgs.tmux ];

      buildPhase = ''
        set -x
        mkdir -p plugins
      '' + builtins.concatStringsSep "\n" (map (p: ''
        echo run-shell ${p.rtp} >> source_plugins
      '') plugins) + ''
        cat ${./.tmux.conf} source_plugins > .tmux.conf
      '';

      installPhase = ''
        mkdir -p $out/share $out/bin
        cp .tmux.conf $out/share/.tmux.conf
        makeWrapper ${pkgs.tmux}/bin/tmux $out/bin/tmux \
          --add-flags "-f $out/share/.tmux.conf"
      '';
    });

in tmux ([ sidebar vim-tmux-navigator tmux-gruvbox tmux-yank ])
