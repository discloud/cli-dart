const discloudURL = "https://discloud.com";
const discloudDashboardURL = "$discloudURL/dashboard";
const discloudApikeyURL = "$discloudDashboardURL/apikey";
const discloudLegalURL = "$discloudURL/legal";
const discloudPlansURL = "$discloudURL/plans";

const Map<String, Set<String>> blockedFiles = {
  "common": {".git", ".vscode", ".cache", "temp"},
  "go": {},
  "js": {"node_modules", "package-lock.json", "yarn.lock", ".npm"},
  "py": {".venv"},
  "rb": {"Gemfile.lock"},
  "rs": {"Cargo.lock", "target"},
  "ts": {"node_modules", "package-lock.json", "yarn.lock", ".npm"},
};

final allBlockedFiles = {for (final e in blockedFiles.values) ...e};

const availableLangs = {
  "go",
  "javascript",
  "java",
  "python",
  "ruby",
  "typescript",
};
