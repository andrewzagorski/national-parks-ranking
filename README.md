# The Parks Rubric

### About

Parks Rubric was built by someone with a love for ranking things and a passion for nature. Users can rank parks across key metrics and see how their preferences align with the community. Key features include

- Rank parks across 8 metrics
- Adjust weights for each metric
- See community rankings
- Save preferences: customize rankings and weights
- No login required - users get a unique ID for data recovery. Your data is never used for tracking or advertising

### Tech Stack

| Layer    | Choice                       |
| -------- | ---------------------------- |
| Frontend | Vue 3 + Vite + Pinia         |
| Database | Supabase                     |
| Hosting  | Cloudflare Pages             |
| Auth     | Automatically generated UUID |

### Contributing

Sure, why not.

### TODO list

- Add images for each park
- Add more themes
- Themes save to user profile to apply on login
- Add "tiebreaker" functionality
- Hover the score post-it to view the score breakdown by metric
- Comments
- Global weights are adjusted in accordance with aggregate user preferences (automatically daily)
- User can save their weights as a preset; views global rankings according to their weights
- Custom site branding, icon, favicon
- Take the weighted scores and normalize them on a curve to give A+->F
