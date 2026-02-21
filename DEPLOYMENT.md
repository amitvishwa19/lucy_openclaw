# Deployment Guide for Ashacarewell Landing Page

## Files Included
- `landing.html` — Complete landing page with all styles inline (no external dependencies except Google Fonts)
- `website-design-package.md` — Brand identity, color palette, typography, design specs

## How to Deploy (3 Easy Options)

### Option 1: Direct File Upload (Easiest)
1. Login to your hosting control panel (cPanel, Plesk, etc.)
2. Navigate to `public_html` or your domain's root folder
3. Upload `landing.html` as `index.html`
4. Done! Your site is live at www.ashacarewell.com

### Option 2: Use Netlify/Vercel (Free Hosting)
1. Create a GitHub repo with:
   - `landing.html` (rename to `index.html`)
   - `CNAME` file with your domain
2. Import repo to Netlify/Vercel
3. Set custom domain
4. Enable HTTPS (automatic)

### Option 3: AWS S3 + CloudFront
1. Upload `landing.html` to an S3 bucket
2. Enable static website hosting
3. Point CloudFront to S3
4. Update DNS to CloudFront

## Before Going Live

1. **Replace placeholder content:**
   - Dashboard image: create/upload `dashboard-mockup.png` (or change the `src` in HTML)
   - Testimonials: replace with real customer photos/quotes
   - Contact info: ensure WhatsApp number is correct

2. **Add analytics:**
   - Add Google Analytics tracking code in `<head>`
   - Add Facebook Pixel if needed

3. **Connect forms:**
   - "Start Free Trial" button should link to a signup form (Google Form, Typeform, or custom backend)
   - Or set up a WhatsApp link: `https://wa.me/919712340450?text=Hi%20Ashacarewell%20-%20Interested%20in%20trial`

4. **SEO basics:**
   - Add `<meta name="description" content="...">` (already there)
   - Submit sitemap to Google Search Console
   - Build some backlinks from healthcare sites

5. **Legal:**
   - Add Privacy Policy page
   - Add Terms of Service
   - Mention data security (ISO compliance if you have it)

## Customization Tips

- **Colors:** Search/replace hex codes if you want a different palette
- **Fonts:** Swap Inter for Poppins or Roboto via Google Fonts
- **Animations:** Add hover effects (already smooth)
- **Mobile:** Already responsive, test on real devices

---

**Need help?** Just ask your assistant Lucy! 👻
