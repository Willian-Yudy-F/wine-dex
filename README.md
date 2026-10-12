# 🍷 Wine Dex

**A Pokédex for wine.** Photograph the bottle, write what you think, and see how your taste compares with everyone else who logged the same wine. Built as a mobile-first web app you can open from your phone's browser — no app store, no install.

> Inspired by Vivino, built from seven years behind the bar. Every wine you log gets a number in *your* cellar (#001, #002…), just like a Pokédex.

| My cellar | Wine detail & comparison | Log a wine | Explore |
| --- | --- | --- | --- |
| ![Cellar](docs/cellar.png) | ![Detail](docs/detail.png) | ![Form](docs/form.png) | ![Explore](docs/explore.png) |

## Features

- **Snap the bottle** – uses the phone camera directly (`<input capture="environment">`); photos are resized in the browser before upload so they are fast on mobile data.
- **Personal notes** – star rating (1–5, half steps), flavour tags ("Dark fruit", "Oak", "Long finish"…), free-text note, price, place and date.
- **Compare with everyone** – each wine shows *your* rating next to the community average, a 1–5 rating distribution, the flavour tags people mention most, and a one-line verdict ("You like it more than others do (+0.7)").
- **Taste match** – the Explore tab scores how often you land within half a star of the crowd, and where you drift (reds +0.3, whites −0.4).
- **Shared wine catalogue** – the same wine logged by two people is stored once (`wines`) with many tastings (`tastings`), so comparisons actually line up.
- **Search & filters** – filter the cellar by wine type, free-text search by name, producer, grape, region; Explore lists what everyone is drinking, sorted by number of tasters.
- **Installable (PWA)** – add to home screen; the app shell works offline.
- **Demo mode** – with no Supabase keys the app runs entirely in the browser (localStorage), so you can try it in 10 seconds.

## Stack

| Layer | Choice | Why |
| --- | --- | --- |
| Front end | Vanilla HTML / CSS / JavaScript, single `index.html` | Nothing to build, loads instantly on a phone, easy to read |
| Hosting | GitHub Pages | Free, HTTPS (needed for the camera and PWA) |
| Auth | Supabase Auth – magic link by e-mail | No passwords to manage |
| Database | Supabase PostgreSQL with Row Level Security | Everyone can read all tastings (community average); each person can only write their own rows |
| Photos | Supabase Storage bucket `wine-photos` | Public read, per-user upload folder enforced by policy |

```
index.html        app (UI + logic)
config.js         Supabase URL + anon key (public, protected by RLS)
supabase/
  schema.sql      tables, view, RLS and storage policies
manifest.json     PWA manifest
sw.js             service worker (offline shell)
icon.svg          app icon
docs/             screenshots
```

### Data model

```
wines (id, name, producer, vintage, wine_type, grape, country, region, created_by)
   1 ──< tastings (id, wine_id, user_id, taster_name, rating, notes, tags[], photo_url, price, place, tasted_at)
wine_stats (view): wine_id, tasting_count, avg_rating, taster_count
```

## Run it yourself

1. **Create a Supabase project** (free tier is enough). Choose a region close to you.
2. In **SQL Editor**, paste and run [`supabase/schema.sql`](supabase/schema.sql). This creates the tables, the `wine_stats` view, RLS policies and the `wine-photos` bucket.
3. In **Authentication → URL Configuration**, set *Site URL* to where the app will live (e.g. `https://<you>.github.io/wine-dex/`) and add it to *Redirect URLs*.
4. Copy **Project URL** and **anon public key** from *Project Settings → API* into `config.js`.
5. Push to GitHub and enable **Settings → Pages → Deploy from branch (main, root)**.
6. Open the URL on your phone, enter your e-mail, tap the magic link, and log your first bottle.

To try it without any backend, just open `index.html` from any static server – it starts in demo mode.

## Roadmap

- [ ] Read the label with AI (vision model) to pre-fill name, producer and vintage from the photo
- [ ] Food-pairing tags and a "would buy again" flag
- [ ] Friends: compare only with people you follow
- [ ] Export your cellar as CSV

## Design

The UI was designed first as four phone artboards in Claude Design (cellar, detail, log, explore) and then built by hand: dark cellar ground `#140A0E`, gold accent `#D9B36A`, wine red `#B8304A`, Fraunces for display type and Manrope for text, inline SVG icons, 44 px touch targets.

## About

Built by [Willian Yudy Futema](https://willian-yudy-f.github.io/) — IT Support Coordinator at Merivale (Allianz Stadium & SCG) and a bartender for many years before that. This project combines what I know about wine service with what I am learning in data and web development.

MIT License.
