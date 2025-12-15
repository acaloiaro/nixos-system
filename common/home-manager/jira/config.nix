{
  endpoint = "https://greenhouseio.atlassian.net";
  login = "adriano.caloiaro@greenhouse.io";
  authentication-method = "api-token";
  password-source = "gopass";
  password-name = "atlassian.com/jira-cli";
  project = "GREEN";
  # team = "TOPS";
  overrides = {
    team_name = "Post-Hire Ecosystem";
    # team_id = "19c2cd93-cb4e-46af-a8cb-37a64c1e3ec4";
    user = "557058:d182f6fb-29c2-4608-b08f-b0ad024d98cb";
  };
  custom-commands = [
    {
      name = "mine-in-progress";
      help = "display issues assigned to me";
      script = ''
        {{jira}} list --query "resolution = unresolved AND assignee=currentuser() AND type != epic AND status = 'In Progress'"
      '';
    }
    {
      name = "mine";
      help = "display issues assigned to me";
      script = ''
        {{jira}} list --query "resolution = unresolved AND assignee=currentuser() AND type != epic AND status != 'Done' AND status != 'Cancelled' ORDER BY status"
      '';
    }
    {
      name = "mine-table";
      help = "display issues assigned to me";
      script = ''
        {{jira}} list --query "resolution = unresolved AND assignee=currentuser() AND type != epic AND status != 'Done' ORDER BY created" --template table
      '';
    }
    {
      name = "to-planned";
      help = "transition issue to Planned";
      args = [
        {
          name = "issue";
          help = "issue to transition to planned";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "Planned" {{args.issue}}
      '';
    }
    {
      name = "to-in-progress";
      help = "transition issue to In Progress";
      args = [
        {
          name = "issue";
          help = "issue to transition to in progress";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "In Progress" {{args.issue}}
      '';
    }
    {
      name = "to-code-review";
      help = "transition issue to Code Review";
      args = [
        {
          name = "issue";
          help = "issue to transition to code review";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "Code Review" {{args.issue}}
      '';
    }
    {
      name = "to-to-be-tested";
      help = "transition issue to To Be Tested";
      args = [
        {
          name = "issue";
          help = "issue to transition to to be tested";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "To Be Tested" {{args.issue}}
      '';
    }
    {
      name = "to-testing";
      help = "transition issue to Testing";
      args = [
        {
          name = "issue";
          help = "issue to transition to to be testing";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "Testing" {{args.issue}}
      '';
    }
    {
      name = "to-verified";
      help = "transition issue to Verified";
      args = [
        {
          name = "issue";
          help = "issue to transition to to be verified";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "Verified" {{args.issue}}
      '';
    }
    {
      name = "wont-fix";
      help = "transition issue to Won't Fix";
      args = [
        {
          name = "issue";
          help = "issue to transition to Won't Fix";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "Won't Fix" {{args.issue}}
      '';
    }
    {
      name = "to-done";
      help = "transition issue to Done";
      args = [
        {
          name = "issue";
          help = "issue to transition to to be done";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "Done" {{args.issue}}
      '';
    }
    {
      name = "to-released";
      help = "transition issue to Released";
      args = [
        {
          name = "issue";
          help = "issue to transition to to be released";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "Released" {{args.issue}}
      '';
    }
    {
      name = "to-do";
      help = "Issues on deck";
      script = ''
        {{jira}} list --query "status = 'To Do' AND project = 'GREEN' AND type != epic order by rank" --template table
      '';
    }
    {
      name = "planned";
      help = "Issues on deck";
      script = ''
        {{jira}} list --query "status = planned AND project = 'GREEN' AND type != epic order by rank" --template table
      '';
    }
    {
      name = "gh-in-progress";
      help = "Issues in progress";
      script = ''
        {{jira}} list --query "status = 'In Progress' AND project = 'GREEN' AND type != epic order by rank" --template table
      '';
    }
    {
      name = "in-process";
      help = "Issues in process";
      script = ''
        {{jira}} list --query "status in ('To Be Tested', 'Testing', 'Code Review', 'Waiting for Code Review', 'Test Case Review', 'Product Review', 'Verified by QA') AND project = 'GREEN' AND type != epic order by rank" --template table-simple
      '';
    }
    {
      name = "in-backlog";
      help = "Issues in backlog";
      script = ''
        {{jira}} list --query "status in ('Backlog') AND project = 'GREEN' AND type != epic order by rank" --template table
      '';
    }
    {
      name = "in-to-be-tested";
      help = "Issues in to be tested";
      script = ''
        {{jira}} list --query "status in ('To Be Tested') AND project = 'GREEN' AND type != epic order by rank"
      '';
    }
    {
      name = "gh-done";
      help = "Issues done";
      script = ''
        {{jira}} list --query "resolution = done AND project = 'GREEN' AND type != epic AND resolutiondate > -4d order by rank" --template table
      '';
    }
    {
      name = "epic show";
      help = "Show summary of epic and issues in it";
      args = [
        {
          name = "issue";
          help = "issue to transition to to be released";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} view {{args.issue}};
        {{jira}} epic list {{args.issue}} -t view-epic
      '';
    }
    {
      name = "epic ours";
      help = "display epics assigned to us";
      script = ''
        {{jira}} list --query 'issuetype = Epic AND project = "GREEN"'
      '';
    }
    {
      name = "archive";
      help = "archive an issue";
      args = [
        {
          name = "issue";
          help = "issue to archive";
          type = "string";
          required = true;
        }
      ];
      script = ''
        {{jira}} transition "Archive" {{args.issue}}
      '';
    }
    {
      name = "sprint";
      help = "display issues for active sprint";
      script = ''
        {{jira}} list --template table --query "sprint in openSprints() AND type != epic AND resolution = unresolved AND project=$JIRA_PROJECT ORDER BY rank asc, created"
      '';
    }
  ];
}
