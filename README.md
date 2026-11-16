# Iron Grind Gym Management Portal

Iron Grind is a web-based gym management portal developed for the capstone study. This repository contains the application, shared assets, and Supabase backend files.

## Project map

| Location | Contents |
| --- | --- |
| `index.html`, `admin.html`, `staff.html`, `customer.html`, `register.html`, `reset-password.html`, `attendance-phone.html` | Portal pages and workflows |
| `assets/` | Shared styles, scripts, and images |
| `supabase/functions/` | Supabase Edge Functions |
| `supabase/migrations/` | Versioned database schema changes |

Study and defense deliverables are kept locally in `Documentations/` and are intentionally excluded from this GitHub repository. They are not runtime dependencies of the application.

## Run the portal locally

Requirements: Node.js 20 or later.

```powershell
npm install
npm start
```

Open <http://127.0.0.1:4173>. The local server serves the project files; Supabase services and deployment are managed separately.