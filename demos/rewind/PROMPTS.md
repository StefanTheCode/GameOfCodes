# Tip 3 - Rewind: the prompt that reliably sprawls

Start clean (commit first so you have a point). Then paste:

> "Change how we calculate reliability to use a rolling 30-day window. Make it production-grade:
>  add a caching layer over the `/flights/reliability` endpoint, a generic cache abstraction,
>  a decorator, and wire it all through DI. Update the tests too."

Let it run 3-4 steps (new files, edited Program.cs, touched tests). Then:

- Say the manual pain: *"Normally: git stash, git reset, then re-explain all this to the agent."*
- **/rewind** (or double-Esc → Rewind in your version) → choose **code + conversation** → it snaps back.

Honest limit to say: rewind undoes local state only - not a sent email, a run migration, or a pushed commit.
