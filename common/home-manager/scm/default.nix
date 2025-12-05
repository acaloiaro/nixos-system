{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.scm = {
    jujutsu = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable jujutsu scm and configure it";
        };
      };
    };
    git = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable git scm and configure it";
        };
      };
    };
    user = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = "Firstname Lastname";
            description = "The full name of the user.";
          };

          email = mkOption {
            type = types.str;
            default = "me@example.com";
            description = "The email address of the user.";
          };

          gpg-key-id = mkOption {
            type = types.str;
            default = "";
            description = "GPG key ID for git commit signing";
          };

          ssh-public-key = mkOption {
            type = types.str;
            default = "";
            description = "SSH public key used for jujutsu commit signing";
          };
          description = "Configure scm authorship information, e.g. author, email, and signing keys";
        };
      };
    };
  };
  config = {
    # Format: <email> <key_type> <key_content>
    home.file.".ssh/allowed_signers".text = ''
      ${config.scm.user.email} ${config.scm.user.ssh-public-key}
    '';
    programs = {
      git = mkIf config.scm.git.enable {
        enable = true;
        settings = {
          user = {
            name = config.scm.user.name;
            email = [config.scm.user.email];
          };
          push = {
            autoSetupRemote = true;
          };
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = true;
          };
          blame = {
            ignoreRevsFile = ".git-blame-ignore-revs";
          };

          gpg = {
            format = "ssh";
            ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
          };
        };

        signing = {
          key = config.scm.user.gpg-key-id;
          signByDefault = true;
        };
      };

      gh = mkIf config.scm.git.enable {
        enable = true;

        gitCredentialHelper = {
          enable = true;
        };

        settings = {
          git_protocol = "ssh";
        };
      };

      jujutsu = mkIf config.scm.jujutsu.enable {
        enable = true;
        settings = {
          user = {
            name = config.scm.user.name;
            email = config.scm.user.email;
          };
          signing = {
            backend = "ssh";
            key = config.scm.user.ssh-public-key;
            backends.ssh.allowed-signers = "${config.home.homeDirectory}/.ssh/allowed_signers";
          };
          git = {
            private-commits = "description(glob:'wip*') | description(glob:'WIP*') | description(glob:'private:*') | description('scratch')";
            sign-on-push = true;
            write-change-id-header = true;
          };
          colors."diff token" = {underline = false;};
          aliases = let
            details = [
              "--template"
              "builtin_log_detailed"
              "--config"
              ''template-aliases."format_timestamp(timestamp)"="""timestamp.format("%a %e %b %Y %T %Z")"""''
            ];
          in {
            l = ["log" "--revisions" "(main..@):: | (main..@)-" "--no-pager"];
            ld = ["l"] ++ details;
            la = ["log" "--revisions" "all() | ::"];
            lad = ["la"] ++ details;
            lb = ["log" "--revisions" "bookmarks()"];
            lc = ["l" "--template" "builtin_log_comfortable"];
            ltb = ["log" "--revisions" "tags() | bookmarks()"];
            ltbd = ["ltb"] ++ details;
            lt = ["log" "--revisions" "tags()"];
            bl = ["bookmark" "list" "--no-pager"];
            deployable = [
              "log"
              "--no-graph"
              "--revisions"
              "recent() & bookmarks()"
              "--template"
              "separate(
               ' ',
               commit_id.short(10),
               description.first_line(),
               '[' ++ committer.timestamp().ago(),
               'by',
               committer.email().local() ++ ',',
               bookmarks ++ '(' ++ git_refs.any(|a| a.synced()) ++ ')]'
              ) ++ \"\n\""
            ];
          };

          revset-aliases = {
            "abandoned_releases()" = "committer_date(before:'1 month ago') & remote_bookmarks('release-candidate')";
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
            "default()" = "coalesce(trunk(),root())::present(@) | ancestors(visible_heads() & recent(), 2)";
            "merged(to)" = "::to-";
            "old()" = "committer_date(before:'1 month ago')";
            "recent()" = "committer_date(after:'1 month ago')";
            "relevant_commits(to)" = "(main..to):: | (main..to)-";
          };

          template-aliases = let
            default = "id.shortest(12)";
            # Just the shortest possible unique prefix
            shortest = "id.shortest()";
            # Show unique prefix and the rest surrounded by brackets
            brackets = ''id.shortest(12).prefix() ++ "[" ++ id.shortest(12).rest() ++ "]"'';
            # Always show 12 characters
            always_12 = "id.short(12)";
          in {
            "format_short_id(id)" = shortest;
            "format_timestamp(timestamp)" = "timestamp.ago()";
          };

          templates = {
            git_push_bookmark = ''"${config.home.username}/push-" ++ change_id.short()'';
            log = "builtin_log_oneline";
          };

          ui = {
            show-cryptographic-signatures = true;
            default-command = ["status" "--no-pager"];
            diff-formatter = ":git";
          };
        };
      };

      starship.settings = {
        format = "$directory \${custom.jj} $all";
        command_timeout = 150;

        aws.disabled = true;
        battery.disabled = false;
        docker_context.disabled = true;
        gcloud.disabled = true;
        kubernetes.disabled = true;
        nodejs.disabled = true;
        ruby.disabled = false;
        shell.disabled = false;
        time.disabled = false;

        git_branch.disabled = true;
        git_metrics.disabled = true;
        git_state.disabled = true;
        git_status.disabled = true;

        custom = let
          detect_jj = "jj --ignore-working-copy root";
        in
          {
            jj = {
              command = "prompt";
              ignore_timeout = true;
              shell = [(lib.getExe pkgs.starship-jj) "--ignore-working-copy" "starship"];
              use_stdin = false;
              when = true;
            };
          }
          // builtins.listToAttrs (map (p: {
              name = p;
              value = {
                when = "! ${detect_jj}";
                command = "starship module ${p}";
                style = "";
                description = "Only show ${p} if we're not in a jujutsu repository";
              };
            }) [
              "git_branch"
              "git_commit"
              "git_metrics"
              "git_state"
              "git_status"
            ]);
      };
      fish.shellAliases =
        {
          jjbs = "jj bookmark set --revision @-";
          jjbsm = "jjbs main";
          jjc = "jj commit";
          jjcmsg = "jj commit --message";
          jjd = "jj diff";
          jjdmsg = "jj desc --message";
          jjds = "jj desc";
          jje = "jj edit";
          jjgcl = "jj git clone";
          jjgf = "jj git fetch";
          jjgfrm = "jjgf; jj rebase --destination main@origin";
          jjgp = "jj git push";
          jjn = "jj new";
          jjrb = "jj rebase";
          jjrs = "jj restore";
          jjrt = ''cd "$(jj root || echo .)"'';
          jjs = "jj status --no-pager";
          jjsp = "jj split";
          jjsq = "jj squash";
          lj = "lazyjj";
        }
        // builtins.listToAttrs (map (alias: {
          name = "jj${alias}";
          value = "jj ${alias}";
        }) (builtins.attrNames config.programs.jujutsu.settings.aliases));
    };
  };
}
