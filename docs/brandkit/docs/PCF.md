# PCF integration — the parts that bite

Fluent v9 inside a PCF control is not the same as Fluent v9 in a React app.
Five things behave differently. Each of these has cost real debugging time.

## 1. `targetDocument` is not optional

Fluent v9 styles with Griffel, which injects a `<style>` tag at runtime. It
injects into `document` by default. A PCF control hosted in a **dialog, side
pane, or custom page** may be in a different document context, and the styles
land somewhere the control cannot see.

```tsx
<FluentProvider theme={theme} targetDocument={window.document}>
```

Symptom when missing: the control renders completely unstyled in a dialog but
looks fine on a form.

## 2. `applyStylesToPortals` — the dropdown bug

Menus, tooltips, dropdowns and dialogs **portal outside** the control's DOM
subtree. Without `applyStylesToPortals`, portalled content renders with no
theme at all — a white, unbranded dropdown floating over a branded control.

```tsx
<FluentProvider theme={theme} applyStylesToPortals>
```

This is the single most reported "my PCF control looks broken" issue with
Fluent v9. `CaldovaPcfProvider` sets it for you.

## 3. Use virtual controls, not standard

```xml
<control … control-type="virtual">
  <platform-library name="React" version="16.14.0" />
  <platform-library name="Fluent" version="9.46.2" />
```

Virtual controls **share the host's React and Fluent instances**. Bundling
your own copy gives you two Fluent style registries writing to the same
document, which produces intermittent, un-debuggable style conflicts — and a
bundle several hundred KB larger, per control, on every form.

Check the platform's supported Fluent version before pinning: it moves, and a
mismatch fails at load time rather than at build time.

## 4. Host theme bridging — decide precedence deliberately

`context.fluentDesignLanguage` carries the maker-configured theme. It is
**optional** — canvas apps, older hosts and the test harness all omit it.
Always guard.

The kit applies a deliberate precedence:

```
Caldova brand  >  host theme  >  Fluent defaults
```

We inherit **only** host-owned accessibility concerns (font size and line
height scaling, which users control in personalization settings). We do
**not** inherit host colours — otherwise a maker changing the app theme
silently unbrands every Caldova control on the form.

If your control is meant to blend into a maker-themed app rather than carry
Caldova brand, invert that in `usePowerAppsTheme.ts`. Make it a decision, not
an accident.

## 5. Transparent background

A PCF control sits inside a form section that already has a background.
`FluentProvider` paints `colorNeutralBackground1` by default, producing a
visible rectangle that does not line up with the form. The kit sets
`background: transparent` on the provider and lets `CaldovaSurface` own the
surface instead.

---

## Build and deploy

```bash
npm i
npm run build                     # pac pcf build
pac pcf push --publisher-prefix crmshow
```

Test both themes before shipping:

```bash
npm start watch                   # harness — note: NO fluentDesignLanguage here
```

The harness does not provide the host theme, so it exercises the fallback
path. Always also test on a real form in a real environment, in **both** the
default and a dark app theme.

## Accessibility checklist for a control

- [ ] Keyboard reachable, visible focus indicator (Fluent gives this — do not remove outlines)
- [ ] Brand red not used as the only carrier of meaning
- [ ] Text meets 4.5:1 — see `docs/ACCESSIBILITY.md` for the measured table
- [ ] Announced correctly by a screen reader when the bound value changes
- [ ] Works at 200% text scaling and at the host's font-scale setting
