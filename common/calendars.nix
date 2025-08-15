{config, ...}: {
  accounts.calendar = {
    basePath = "${config.xdg.dataHome}/calendars";

    accounts = {
      fastmail = {
        khal = {
          enable = true;
          color = "light green";
        };

        local = {
          type = "filesystem";
          fileExt = ".ics";
        };

        remote = {
          type = "caldav";
          userName = "me@adriano.fyi";
          url = "https://caldav.fastmail.com/dav/calendars/user/me@adriano.fyi/4812c3f7-e1bb-42fc-ac5c-0ce69d8dd7e0/";
        };

        vdirsyncer = {
          enable = true;
          metadata = ["color"];
          conflictResolution = "remote wins";
        };
      };
    };
  };

  programs = {
    vdirsyncer.enable = true;

    khal = {
      enable = true;

      locale = {
        timeformat = "%H:%M";
        dateformat = "%Y-%m-%d";
        longdateformat = "%Y-%m-%d";
        datetimeformat = "%Y-%m-%d %H:%M";
        longdatetimeformat = "%Y-%m-%d %H:%M";
      };

      settings = {
        default = {
          default_calendar = "fastmail";
          timedelta = "2d";
        };
        view = {
          agenda_event_format = "{calendar-color}{cancelled}{start-end-time-style} {title}{repeat-symbol}{reset}";
        };
      };
    };
  };

  services.vdirsyncer.enable = true;
}
