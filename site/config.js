// Connection details for the church database (Supabase).
// Fill these in from Supabase → Project Settings → API Keys / Data API. See DEPLOY.md, step 3.
// Both values are safe to publish: the database's access rules decide who can see or change anything.
window.ZION_CONFIG = {
  supabaseUrl: "https://orlejnsdcrygpubhdjxe.supabase.co",
  supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ybGVqbnNkY3J5Z3B1YmhkanhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTExNjA2MzMsImV4cCI6MjEwNjczNjYzM30.vtZQX9_Iks0ktBjTR5c48cCZE6T9Fq-O6Z_bZy174Gg",
  // Where "Sundays & Seasons" buttons go. If you find that a day's page has the date in its
  // address, put {date} where the date goes (YYYY-MM-DD) and each Sunday will open directly.
  sundaysSeasonsUrl: "https://members.sundaysandseasons.com/"
};
