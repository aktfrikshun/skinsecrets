# Olga's Skin Secrets - Static Website

This is a static website for Olga's Skin Secrets, a professional esthetician services business.

## Structure

```
.
├── index.html          # Home page
├── about.html          # About page
├── services.html       # Services page
├── contact.html        # Contact page
├── assets/
│   └── images/        # Images (logo, icons)
└── README.md          # This file
```

## Features

- **Fully Static**: No server-side processing required
- **Responsive Design**: Works on all devices (mobile, tablet, desktop)
- **Modern Styling**: Uses Tailwind CSS via CDN
- **Beautiful Typography**: Google Fonts integration
- **Icons**: Font Awesome icons
- **Contact Form**: Uses mailto: links (can be replaced with Formspree or similar service)

## Deployment Options

### Option 1: GitHub Pages

1. Create a new GitHub repository
2. Push the files to the repository
3. Go to Settings > Pages
4. Select the branch and folder (usually `main` and `/`)
5. Your site will be available at `https://yourusername.github.io/repository-name`

### Option 2: Netlify

1. Create a Netlify account
2. Drag and drop the project folder to Netlify
3. Your site will be live immediately with a free `.netlify.app` domain

### Option 3: Vercel

1. Install Vercel CLI: `npm i -g vercel`
2. Navigate to the project directory
3. Run `vercel`
4. Follow the prompts to deploy

### Option 4: Traditional Web Hosting

1. Upload all files to your web server
2. Ensure `index.html` is in the root directory
3. Access via your domain name

### Option 5: AWS S3 + CloudFront

1. Create an S3 bucket
2. Upload all files to the bucket
3. Enable static website hosting
4. Optionally set up CloudFront for CDN

## Customization

### Contact Form

The contact form currently uses a `mailto:` link. For better functionality, consider:

1. **Formspree** (Free tier available)
   - Sign up at https://formspree.io
   - Replace the form action with your Formspree endpoint

2. **Netlify Forms** (If using Netlify)
   - Add `netlify` attribute to the form
   - Add `data-netlify="true"` to the form tag

3. **EmailJS** (Free tier available)
   - Sign up at https://www.emailjs.com
   - Add JavaScript to handle form submission

### Images

All images are in `assets/images/`. To add new images:
1. Place them in `assets/images/`
2. Update the HTML to reference them with relative paths

### Styling

The site uses Tailwind CSS via CDN. To customize:
- Modify the `tailwind.config` object in each HTML file's `<script>` tag
- Or download Tailwind CSS and build locally for production

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Notes

- All pages are self-contained with navigation and footer
- No JavaScript framework dependencies
- All external resources (fonts, icons, CSS) are loaded via CDN
- The site is SEO-friendly with proper meta tags and semantic HTML

## Maintenance

To update content:
1. Edit the HTML files directly
2. Update images in `assets/images/`
3. Redeploy to your hosting platform

## License

© 2024 Olga's Skin Secrets. All rights reserved.

