final: prev: {
  go-jira = prev.go-jira.overrideAttrs (o: {
    patches = (o.patches or []) ++ [./patches/go-jira-search-fix.patch];
  });
}
