#!/usr/bin/env bun
//
// Workspace PR Status — writes a `pr` metadata token onto each Herdr workspace
// so the sidebar can render a PR status line *under the workspace* (as opposed
// to the wyattjoh/gh-pr plugin, which is pane/agent-scoped).
//
// Render it by listing $pr in a [ui.sidebar.spaces] row, e.g.
//   [ui.sidebar.spaces]
//   rows = [["state_icon", "workspace"], ["branch", "git_status"], ["$pr"]]
//
// Token is cleared (line collapses) when a workspace has no resolvable git
// repo, no branch, or the branch has no PR. Output is words, including an
// "approved" / "changes" review marker when GitHub reports a review decision.

import { $ } from "bun";

const SOURCE = "workspace-pr";
const TOKEN = "pr";

// ── Herdr JSON shapes (only the fields we read) ──────────────────────────────

interface WorkspaceListEntry {
  workspace_id: string;
  active_tab_id?: string;
  worktree?: { checkout_path?: string };
}

interface PaneEntry {
  pane_id: string;
  tab_id?: string;
  cwd?: string;
  foreground_cwd?: string;
  focused?: boolean;
}

// ── Herdr helpers ────────────────────────────────────────────────────────────

async function listWorkspaces(): Promise<WorkspaceListEntry[]> {
  const out = await $`herdr workspace list`.nothrow().quiet();
  if (out.exitCode !== 0) return [];
  try {
    const parsed = JSON.parse(out.stdout.toString());
    const ws = parsed?.result?.workspaces;
    return Array.isArray(ws) ? ws : [];
  } catch {
    return [];
  }
}

async function focusedWorkspaceId(): Promise<string | null> {
  const ws = await listWorkspaces();
  const focused = ws.find((w) => (w as { focused?: boolean }).focused);
  return focused?.workspace_id ?? null;
}

// Resolve a workspace's working directory. Prefer the git worktree checkout
// path Herdr already tracks; otherwise fall back to a pane's cwd (the shell's
// directory, which for an agent pane is the project root it launched from).
async function resolveWorkspaceCwd(ws: WorkspaceListEntry): Promise<string | null> {
  const checkout = ws.worktree?.checkout_path;
  if (checkout) return checkout;

  const out = await $`herdr pane list --workspace ${ws.workspace_id}`.nothrow().quiet();
  if (out.exitCode !== 0) return null;
  let panes: PaneEntry[] = [];
  try {
    const parsed = JSON.parse(out.stdout.toString());
    panes = Array.isArray(parsed?.result?.panes) ? parsed.result.panes : [];
  } catch {
    return null;
  }
  if (panes.length === 0) return null;

  // Prefer a pane on the active tab, then the focused pane, then anything.
  const activeTab = ws.active_tab_id;
  const ordered = [
    ...panes.filter((p) => activeTab && p.tab_id === activeTab),
    ...panes.filter((p) => p.focused),
    ...panes,
  ];
  for (const p of ordered) {
    const cwd = p.cwd ?? p.foreground_cwd;
    if (cwd) return cwd;
  }
  return null;
}

async function setToken(workspaceId: string, text: string): Promise<void> {
  await $`herdr workspace report-metadata ${workspaceId} --source ${SOURCE} --token ${`${TOKEN}=${text}`}`
    .nothrow()
    .quiet();
}

async function clearToken(workspaceId: string): Promise<void> {
  await $`herdr workspace report-metadata ${workspaceId} --source ${SOURCE} --clear-token ${TOKEN}`
    .nothrow()
    .quiet();
}

// ── git / gh helpers ─────────────────────────────────────────────────────────

async function currentBranch(cwd: string): Promise<string | null> {
  const inside = await $`git -C ${cwd} rev-parse --is-inside-work-tree`.nothrow().quiet();
  if (inside.exitCode !== 0 || inside.stdout.toString().trim() !== "true") return null;
  const branch = await $`git -C ${cwd} rev-parse --abbrev-ref HEAD`.nothrow().quiet();
  if (branch.exitCode !== 0) return null;
  const name = branch.stdout.toString().trim();
  if (!name || name === "HEAD") return null;
  return name;
}

type PrState = "OPEN" | "CLOSED" | "MERGED";
type ReviewDecision = "APPROVED" | "CHANGES_REQUESTED" | "REVIEW_REQUIRED" | "";

interface PullRequest {
  number: number;
  state: PrState;
  reviewDecision: ReviewDecision;
}

async function prInfo(cwd: string, branch: string): Promise<PullRequest | null> {
  const out = await $`gh pr view ${branch} --json number,state,reviewDecision`
    .cwd(cwd)
    .nothrow()
    .quiet();
  if (out.exitCode !== 0) return null;
  try {
    const data = JSON.parse(out.stdout.toString()) as {
      number?: number;
      state?: string;
      reviewDecision?: string;
    };
    if (typeof data.number !== "number") return null;
    const state: PrState =
      data.state === "CLOSED" || data.state === "MERGED" ? data.state : "OPEN";
    const rd = (data.reviewDecision ?? "") as ReviewDecision;
    return { number: data.number, state, reviewDecision: rd };
  } catch {
    return null;
  }
}

type CiRollup = "pass" | "fail" | "pending" | "none";

async function prChecks(cwd: string, branch: string): Promise<CiRollup> {
  // `gh pr checks` exits non-zero when checks fail or are pending; parse anyway.
  const out = await $`gh pr checks ${branch} --json bucket`.cwd(cwd).nothrow().quiet();
  let checks: { bucket?: string }[] = [];
  try {
    const data = JSON.parse(out.stdout.toString());
    checks = Array.isArray(data) ? data : [];
  } catch {
    return "none";
  }
  if (checks.length === 0) return "none";
  const buckets = new Set(checks.map((c) => c.bucket));
  if (buckets.has("fail") || buckets.has("cancel")) return "fail";
  if (buckets.has("pending")) return "pending";
  return "pass";
}

// ── Label composition (words) ────────────────────────────────────────────────

function reviewWord(rd: ReviewDecision): string | null {
  switch (rd) {
    case "APPROVED":
      return "approved";
    case "CHANGES_REQUESTED":
      return "changes";
    // REVIEW_REQUIRED / "" -> no review word (keeps the line short)
    default:
      return null;
  }
}

function ciWord(ci: CiRollup): string | null {
  switch (ci) {
    case "pass":
      return "CI pass";
    case "fail":
      return "CI fail";
    case "pending":
      return "CI pending";
    default:
      return null;
  }
}

function composeLabel(pr: PullRequest, ci: CiRollup): string {
  // Terminal states: PR number + lifecycle word only.
  if (pr.state !== "OPEN") {
    return `#${pr.number} ${pr.state.toLowerCase()}`;
  }
  const parts = [`#${pr.number} open`];
  const review = reviewWord(pr.reviewDecision);
  if (review) parts.push(review);
  const ci_ = ciWord(ci);
  if (ci_) parts.push(ci_);
  return parts.join(" · ");
}

// ── Per-workspace update ─────────────────────────────────────────────────────

async function updateWorkspace(ws: WorkspaceListEntry): Promise<void> {
  const cwd = await resolveWorkspaceCwd(ws);
  if (!cwd) {
    await clearToken(ws.workspace_id);
    return;
  }
  const branch = await currentBranch(cwd);
  if (!branch) {
    await clearToken(ws.workspace_id);
    return;
  }
  const pr = await prInfo(cwd, branch);
  if (!pr) {
    await clearToken(ws.workspace_id);
    return;
  }
  if (pr.state !== "OPEN") {
    await setToken(ws.workspace_id, composeLabel(pr, "none"));
    return;
  }
  const ci = await prChecks(cwd, branch);
  await setToken(ws.workspace_id, composeLabel(pr, ci));
}

// ── Entry points ─────────────────────────────────────────────────────────────

function eventWorkspaceId(): string | null {
  const raw = process.env.HERDR_PLUGIN_EVENT_JSON;
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as { data?: { workspace_id?: string } };
    return parsed?.data?.workspace_id ?? null;
  } catch {
    return null;
  }
}

async function main(): Promise<void> {
  const arg = process.argv[2];

  if (arg === "--closed") {
    // A workspace was closed; clear its token if we can identify it.
    const id = eventWorkspaceId() ?? process.env.HERDR_WORKSPACE_ID ?? null;
    if (id) await clearToken(id);
    return;
  }

  if (arg === "--all") {
    const all = await listWorkspaces();
    // Sequential to avoid a burst of concurrent gh calls; sidebars are small.
    for (const ws of all) await updateWorkspace(ws);
    return;
  }

  // Default: refresh a single workspace — the event's, then the caller's, then
  // whichever is focused.
  const id =
    eventWorkspaceId() ??
    process.env.HERDR_WORKSPACE_ID ??
    (await focusedWorkspaceId());
  if (!id) return;
  const all = await listWorkspaces();
  const ws = all.find((w) => w.workspace_id === id) ?? { workspace_id: id };
  await updateWorkspace(ws);
}

await main();
