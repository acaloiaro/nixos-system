{
  config,
  pkgs,
  ...
}: {
  home = let
    branch-name-ollama = pkgs.writeShellApplication {
      name = "branch-name-ollama";

      runtimeInputs = with pkgs; [
        fzf
        jq
        ollama
      ];

      text =
        # bash
        ''
          set -euo pipefail
          [[ -n "''${DEBUG:-}" ]] && set -x

          export OLLAMA_HOST=''${OLLAMA_HOST:-https://ollama.ai.lan}
          OLLAMA_MODEL=''${OLLAMA_MODEL:-qwen2.5:7b}
          NUM_OPTIONS=''${NUM_OPTIONS:-6}

          main() {
            local summary description choices

            summary=''${1:-$(cat)}
            description=''${2:-}

            choices=$(ollama run "$OLLAMA_MODEL" \
              "You are a helpful assistant that knows how to properly create wonderful git branch names using kebab case.
                - Always return JSON with a key named options and the generated branch names as the values and do not use code blocks.
                - Please only answer with the result, be informative, and do not mention \"branch name\".
                - A good branch name tells the reader what the feature is about and what the changes entail and is about 40-50 characters long.
                - Give me at least ''${NUM_OPTIONS} options.
                - Always weigh more the summary when coming up with good names, and use the description to fill in any details that may not be clear from the summary.
                - Please sort the options alphabetically.

              Please create a git branch name using the following criteria:

              - The summary of the issue is: ''${summary}
              - The description of the issue is: ''${description}

              Thanks")

            <<<"$choices" jq -r '.options[]' |
              fzf --prompt "Pick the best summary for '$summary': "
          }

          main "$@"
        '';
    };

    branch-name = pkgs.writeShellApplication {
      name = "branch-name";

      runtimeInputs = with pkgs; [
        fzf
        jq
        openai
        sso-token-cli
      ];

      text =
        # bash
        ''
          set -euo pipefail
          [[ -n "''${DEBUG:-}" ]] && set -x

          OPENAI_API_KEY=$(sso-token-cli -e self-hosted-llm.dev)
          OPENAI_BASE_URL=''${OPENAI_BASE_URL:-https://qwen2-dev-self-hosted-llm.dev-use1-0.gh.team/v1}
          MODEL=''${MODEL:-Qwen2.5-7B-Instruct-AWQ}
          NUM_OPTIONS=''${NUM_OPTIONS:-6}

          export OPENAI_API_KEY OPENAI_BASE_URL

          main() {
            local summary description choices

            summary=''${1:-$(cat)}
            description=''${2:-}

            choices=$(openai api chat.completions.create \
              --model "$MODEL" \
              --message system "You are a helpful assistant that knows how to properly create wonderful git branch names using kebab case.
                - Always return JSON with a key named options and the generated branch names as the values and do not use code blocks.
                - Please only answer with the result, be informative, and do not mention \"branch name\".
                - A good branch name tells the reader what the feature is about and what the changes entail and is about 40-50 characters long.
                - Give me at least ''${NUM_OPTIONS} options.
                - Always weigh more the summary when coming up with good names, and use the description to fill in any details that may not be clear from the summary.
                - Please sort the options alphabetically." \
              --message user "
              Please create a git branch name using the following criteria:

              - The summary of the issue is: ''${summary}
              - The description of the issue is: ''${description}

              Thanks")

            <<<"$choices" jq -r '.options[]' |
              fzf --prompt "Pick the best summary for '$summary': "
          }

          main "$@"
        '';
    };

    create-branch = pkgs.writeShellApplication {
      name = "create-branch";
      runtimeInputs =
        [
          branch-name
          branch-name-ollama
        ]
        ++ (with pkgs; [
          coreutils
          findutils
          fzf
          git
          gnused
          go-jira
          jq
        ]);

      text =
        # bash
        ''
          set -euo pipefail
          [[ -n "''${DEBUG:-}" ]] && set -x

          BRANCH_NAME_GENERATOR=''${BRANCH_NAME_GENERATOR:-branch-name}

          get_key() {
            jira list \
              --query "resolution = unresolved AND assignee=currentuser() AND type != epic AND status = 'In Progress'" |
              fzf | cut -d: -f1 | xargs
          }

          get_issue() {
            local key
            key="$1"
            jira view "$key" --template debug
          }

          get_summary() {
            local issue
            issue="$1"
            <<<"$issue" jq -rc .fields.summary
          }

          get_description() {
            local issue
            issue="$1"
            <<<"$issue" jq -rc .fields.description
          }

          get_branch_name() {
            local key summary

            key="$1"
            summary="$2"
            description="$3"

            name=$($BRANCH_NAME_GENERATOR "$summary" "$description")

            <<<"''${key}/''${name/ $//}" tr '[:upper:]' '[:lower:]'
          }

          create_branch() {
            local branch_name
            branch_name="$1"
            git checkout -b "${config.home.username}/$branch_name"
          }

          main() {
            local key issue summary

            key=$(get_key)
            issue=$(get_issue "$key")
            summary=$(get_summary "$issue")
            description=$(get_description "$issue")
            branch_name=$(get_branch_name "$key" "$summary" "$description")
            create_branch "$branch_name"
          }

          main "$@"
        '';
    };
  in {
    packages = [branch-name branch-name-ollama create-branch pkgs.go-jira];
    file.".jira.d".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/jira";
  };

  xdg.configFile = {
    "jira/templates" = {
      source = ./templates;
      recursive = true;
    };

    "jira/config.yml".source = let
      yaml = pkgs.formats.yaml {};
    in
      yaml.generate "go-jira-config" (import ./config.nix);
  };
}
