# Iron Grind Gym Management Portal

Iron Grind is a web-based gym management portal developed for the capstone study. This repository contains the portal pages, shared assets, Supabase functions and migrations, and the study and defense materials.

## Project map

| Location | Contents |
| --- | --- |
| `index.html`, `admin.html`, `staff.html`, `customer.html`, `register.html`, `reset-password.html`, `attendance-phone.html` | Portal pages for the supported user roles and workflows |
| `assets/` | Shared styles, scripts, and images |
| `supabase/functions/` | Supabase Edge Functions |
| `supabase/migrations/` | Versioned database schema changes |
| `Documentations/Defense/` | Defense notes, presentation, and setup guides |
| `Documentations/IronGrind – Chapters 1–3.docx` | Current combined manuscript |
| `Documentations/Chapter 3 Diagrams/` | Editable system diagrams and their source material |

## Run the portal locally

Requirements: Node.js 20 or later.

```powershell
npm install
npm start
```

Open <http://127.0.0.1:4173>. The local server serves the project files; Supabase services and deployment are managed separately.

## Defense materials

- [Capstone presentation](Documentations/Defense/Capstone%20Presentation.md)
- [Study and defense notes](Documentations/Defense/Capstone%20Study%20and%20Defense%20Notes.md)
- [Documentation index](Documentations/README.md)
