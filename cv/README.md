# cv/

Put your CV here as `CV.pdf` and the automation will upload it on every form.

```
cv/CV.pdf
```

The CV is deliberately **not** in version control — `.gitignore` excludes `cv/*.pdf`.
The per-channel rulesets reference `linkedin-automation/cv/CV.pdf`; copy or symlink this
file there so every channel picks up the same document:

```bash
mkdir -p linkedin-automation/cv
cp cv/CV.pdf linkedin-automation/cv/CV.pdf
```

Keeping a single canonical CV in `cv/` and copying it out means an update can never leave
one channel uploading a stale version.
