{ config, pkgs, ... }:
{
  services.weechat.enable = true;

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # You'd think this is a good idea, but Safari doesn't support 1.3 on websockets yet from my testing in 2020.  If one is only using Chrome, consider it.
    # sslProtocols = "TLSv1.3";
    virtualHosts = {
      "irc.libera.chat" = {
        forceSSL = true;
        enableACME = true;
        locations."^~ /weechat" = {
          proxyPass = "http://127.0.0.1:9000/weechat/";
          proxyWebsockets = true;
        };
        locations."/" = {
          root = pkgs.glowing-bear;
        };
      };
    };
  };
}


