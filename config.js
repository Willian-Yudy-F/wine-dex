// Wine Dex – Supabase configuration
// Paste the values from Supabase > Project Settings > API.
// The anon key is safe to publish: every table is protected by Row Level Security (see supabase/schema.sql).
// While these are left as placeholders the app runs in "demo mode" and stores everything in the browser only.
window.WINEDEX_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-ANON-KEY",
  PHOTO_BUCKET: "wine-photos",
};
