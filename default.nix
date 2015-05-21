with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "hubert";
  buildInputs = [
    nodejs-0_10
    nodePackages.coffee-script
    git
    python
    icu
    which
    utillinux
  ];
  shellHook = ''
    export HUBOT_NAME='Hubert Test'
    export HUBOT_XMPP_ROOMS=test@conference.mayflower.de,bizdev@conference.mayflower.de
    export HUBOT_XMPP_HOST=jabber.mayflower.de
    export HUBOT_XMPP_USERNAME=hubot@mayflower.de
    export HUBOT_JIRA_USER="hubot"
    export HUBOT_JIRA_URL="https://jira.mayflower.de"

    export HUBOT_ANNOUNCE_ROOMS="$HUBOT_XMPP_ROOMS"

    echo 'set HUBOT_XMPP_PASSWORD, HUBOT_JIRA_PASSWORD'
    echo 'export HUBOT_JIRA_STREAM_URL="https://user:passwd@jira.mayflower.de/activity?maxResults=10&streams=key+IS+ADMIN+OR+key+IS+DEVOPS&os_authType=basic->administrator@conference.mayflower.de,https://user:passwd@jira.mayflower.de/activity?maxResults=10&streams=key+IS+CRM&os_authType=basic->bizdev@conference.mayflower.de"'
  '';
}
