# Zion Worship Musicians — Deployment Guide

This puts the musician sign-up site on the web at an address like
**https://zion-musicians.netlify.app**, with email sign-in links (no passwords).

**Time:** about 45 minutes, once. **Cost:** $0 on the free plans.

## What's in this folder

| Path | What it is |
|---|---|
| `site/` | The website. This whole folder is what you upload to Netlify. |
| `site/config.js` | The only file you edit: it tells the site which database to use. |
| `supabase/schema.sql` | Creates the database tables and access rules. Run once. |
| `supabase/seed.sql` | Optional: loads the October accompanists and the Sept 20 hymns. |

## How the pieces fit

- **Netlify** hosts the web page.
- **Supabase** stores sign-ups, hymns and availability, and handles sign-in.
- **A church Gmail account** sends the sign-in emails. Supabase's built-in email only reaches its own team members and is limited to 2 emails an hour, so this step is required.

> **Tip:** create the Supabase and Netlify accounts with a church-owned email (for example the office account), not a personal one. Then the site doesn't depend on one volunteer.

---

## Step 1 — Create the Supabase project (5 min)

1. Go to **supabase.com** and click **Start your project**. Sign up.
2. Click **New project**:
   - **Name:** `zion-musicians`
   - **Database password:** click *Generate*, then save it somewhere safe (you'll rarely need it).
   - **Region:** *West US* (closest to Camas).
   - **Plan:** Free.
3. Wait about 2 minutes while the project is set up.

## Step 2 — Create the database (5 min)

1. Open `supabase/schema.sql` in any text editor (Notepad, TextEdit).
2. Near the bottom, find the line marked `>>> EDIT <<<`. Replace `you@example.com` with **your** email and `Music Director` with your name. You become the first director.
3. In Supabase, click **SQL Editor** in the left menu, then **New query**.
4. Paste the whole file and click **Run**. You should see *Success. No rows returned.*
5. *(Optional)* Open a new query, paste `supabase/seed.sql`, and click **Run**. This loads Gary, Ethan and Bell for October and the Sept 20 hymns.

## Step 3 — Connect the site to the database (3 min)

1. In Supabase, open **Project Settings** (gear icon), then **API Keys** (older screens: **API**).
2. Copy two values:
   - **Project URL**, which looks like `https://abcdxyz.supabase.co`. It's also shown under **Data API**.
   - The **publishable** key (starts `sb_publishable_`), or on the *Legacy* tab the **anon public** key.
   - **Never** use the `service_role` or *secret* key.
3. Open `site/config.js` and paste them in:

   ```js
   window.ZION_CONFIG = {
     supabaseUrl: "https://abcdxyz.supabase.co",
     supabaseAnonKey: "sb_publishable_xxxxxxxxxxxx"
   };
   ```

   Both values are meant to be public. The access rules from Step 2 decide who can see or change anything.

## Step 4 — Put the site on Netlify (5 min)

1. Go to **netlify.com** and sign up.
2. Click **Add new project** (older screens: *Add new site*), then **Deploy manually**.
3. Drag the **`site` folder** onto the upload area. In a minute you'll get a random address like `https://jolly-tulip-123.netlify.app`.
4. Give it a better name: **Project configuration**, then **Change project name**, then type `zion-musicians`. The address becomes `https://zion-musicians.netlify.app`, or something close if that name is taken.

## Step 5 — Tell Supabase the site's address (2 min)

In Supabase, go to **Authentication**, then **URL Configuration**:

- **Site URL:** `https://zion-musicians.netlify.app` (your address from Step 4)
- **Redirect URLs:** click **Add URL** and enter `https://zion-musicians.netlify.app/**`

Without this, the sign-in link in the email won't bring people back to the site.

## Step 6 — Send sign-in emails from a church Gmail account (15 min)

**In Gmail** (use a church account, e.g. `zionmusic.camas@gmail.com`):

1. Go to **myaccount.google.com**, open **Security**, and turn on **2-Step Verification** if it's off.
2. Go to **myaccount.google.com/apppasswords**. Create an app password named `Supabase` and copy the 16-letter password.

**In Supabase**, go to **Authentication**, then **Emails**, then **SMTP Settings**, and turn on **Enable custom SMTP**:

| Field | Value |
|---|---|
| Sender email | the church Gmail address |
| Sender name | `Zion Worship Musicians` |
| Host | `smtp.gmail.com` |
| Port | `465` |
| Username | the church Gmail address |
| Password | the 16-letter app password |

Click **Save**.

**Optional but nice:** go to **Authentication**, then **Emails**, then **Templates**, then **Magic Link**, and change it to:

- **Subject:** `Your sign-in link for Zion Worship Musicians`
- **Body:**

  ```html
  <p>Hi,</p>
  <p>Tap the button below to sign in to the Zion worship musicians sign-up.</p>
  <p><a href="{{ .ConfirmationURL }}">Sign in</a></p>
  <p>If you didn't ask for this, you can ignore this email.</p>
  ```

## Step 7 — Try it (5 min)

1. Open your site and enter your email. Tap the link in the email; you're signed in as a director.
2. Open the **Musicians** tab and add Pastor and Brandon (name and email). Tick **Director** for anyone who should manage services and hymns.
3. Ask them to visit the site and sign in with that email.
4. **On phones:** open the site and use *Share*, then *Add to Home Screen*. It then works like an app icon.

---

## Everyday use

- **Adding a musician:** Musicians tab, then **Add musician**. Only people on that list can sign in.
- **Someone leaves:** Musicians tab, then **Remove**. Their past sign-ups stay, but they can no longer sign in.
- **Sign-in links** work once and expire after an hour. People stay signed in on that device after that.
- The link signs people in **on the device where they tap it**. If they request it on a computer but tap it on their phone, they're signed in on the phone.

## Updating the site later

The site lives in the **zion-musicians** GitHub repository, and Netlify is linked to it.

1. Edit the files (or have Claude edit the repository).
2. In GitHub Desktop: write a short summary, click **Commit to main**, then **Push origin**.
3. Netlify publishes the change automatically in about a minute. Check **Deploys** in Netlify if it doesn't appear.

Don't drag folders onto Netlify's Deploys page any more. A manual upload would be replaced by the next push from GitHub.
To undo a bad change: in Netlify **Deploys**, open an earlier deploy and click **Publish deploy**. Then fix or revert the change in GitHub.

## Optional: use the church's own web address

To use something like `musicians.zioncamas.org`: in Netlify, open **Domain management**, then **Add a domain**, and follow its DNS instructions with whoever manages the church domain. Then add the new address to Supabase **URL Configuration** (Step 5) as well.

## Keeping it healthy

- **Two owners:** invite a second trusted person to the Supabase organization (**Organization settings**, then **Team**) and the Netlify team. Then nothing is lost if one person steps away.
- **Free-plan pause:** Supabase pauses free projects after about a week with no activity. Weekly sign-ups keep it awake. If it ever pauses (for example over summer), open the Supabase dashboard and click **Restore**.
- **Backups:** the free plan doesn't include downloadable backups. Every few months, use **Table Editor**, then each table, then **Export to CSV**, and keep the files in the church Drive.

## Troubleshooting

| What you see | Fix |
|---|---|
| Yellow **Demo mode** banner on the live site | `config.js` still has the placeholder values. Redo Step 3 and upload the `site` folder again. |
| "We couldn't send the email" | Check the Step 6 SMTP settings. The Gmail app password must be the 16-letter one, not the normal password. |
| Email never arrives | Check the spam folder. In Supabase, **Authentication**, then **Logs**, shows send errors. |
| Link opens a page that says the site can't be reached, or goes to `localhost` | Step 5: Site URL and Redirect URLs must match the Netlify address exactly. |
| "That sign-in link has expired" | Links are single-use and last an hour. Request a new one. |
| "You're not on the musician list yet" | A director adds that exact email in the Musicians tab. |
| A director can't add services or hymns | In the Musicians tab, another director clicks **Make director** for them. |
| "Can't reach the sign-up sheet" | The Supabase project may be paused. Open the dashboard and click **Restore**. |
