# iualkhim42 — Born2beroot Landing Page

## Creative Brief & Technical Specification

**Project:** Born2beroot — 42
**Hostname:** `iualkhim42`
**Operating System:** Debian 13 (Trixie)
**Web Server:** Lighttpd
**Document version:** 1.0
**Status:** Design and implementation planning

---

# 1. Project Overview

## 1.1. Objective

Create a visually distinctive landing page hosted on the `iualkhim42` virtual machine as part of the Born2beroot project.

The page acts as the public-facing entry point to the server, introducing its purpose, presenting the services running on it, and providing convenient access to the associated projects and documentation.

The implementation should demonstrate the ability to build and deploy a website using the infrastructure configured during Born2beroot.

## 1.2. Project Goals

* Introduce the Born2beroot project and its technical purpose.
* Identify the server through its hostname: `iualkhim42`.
* Provide navigation to WordPress, n8n, and the GitHub repository.
* Present key information about the server's technical configuration.
* Apply a consistent visual identity inspired by the Born2beroot space-themed insignia.
* Demonstrate static web hosting using Lighttpd.
* Keep the implementation lightweight, maintainable, and easy to understand.

## 1.3. Target Audience

* 42 students and evaluators.
* Developers interested in Linux and system administration.
* Visitors exploring the services and configuration of the virtual machine.

## 1.4. Design Concept

**Concept:** A small server. A lot going on.

The landing page represents a personal Linux server as a small space exploration station: one machine hosting multiple services, connected through a carefully configured system.

The visual language combines a futuristic space aesthetic with a clean developer-oriented interface.

The design should feel technical, playful, and intentional without becoming visually cluttered.

---

# 2. Brand Identity & Design System

## 2.1. Color Palette

The interface must primarily use the following palette.

| Color           | HEX       | Usage                                                     |
| --------------- | --------- | --------------------------------------------------------- |
| Neon Cyan       | `#00C2FF` | Primary accents, borders, focus states, active indicators |
| Bright Blue     | `#00A3E0` | Interactive elements, illustrations, secondary highlights |
| Space Dark Blue | `#0A113B` | Main background and upper gradient                        |
| Deep Navy       | `#0F1A52` | Cards, lower background, panels and shadows               |
| Lunar Gray      | `#7A84A5` | Secondary text, muted details and subtle outlines         |
| Pure White      | `#FFFFFF` | Main text, headings and high-contrast details             |
| Coral Red       | `#E63946` | Small decorative accents and rocket details               |

### Color Usage Rules

* Dark blue should dominate the interface.
* Neon cyan should guide attention rather than fill large areas.
* White should be used for primary text and important information.
* Lunar gray should distinguish secondary information from headings.
* Coral red should remain a restrained accent.
* Borders and shadows should provide depth without overwhelming the content.
* Text must remain readable against its background.

### Background

Use a dark radial gradient inspired by outer space.

Suggested CSS:

```css
background:
    radial-gradient(
        circle at 50% 0%,
        #0A113B 0%,
        #0F1A52 65%,
        #0A113B 100%
    );
```

Small decorative stars may be added using CSS or lightweight SVG assets. They must remain subtle and must not interfere with text readability.

## 2.2. Typography

### Primary Typeface

**Montserrat**, preferably Bold or ExtraBold for headings and brand elements.

Suggested Google Fonts weights:

* 400 — Regular body text.
* 500 — Secondary labels and navigation.
* 600 — Card headings and section titles.
* 700 — Main headings.
* 800 — Brand title and major emphasis.

Alternative typefaces:

* Nunito Sans — a softer, rounded appearance.
* Fredoka — a more playful, cartoon-inspired identity.

Montserrat is the preferred choice for balancing the space-themed identity with a technical, developer-oriented interface.

### Typography Rules

* Use uppercase text for small section labels, badges, and technical metadata.
* Use sentence case for paragraphs and descriptive content.
* Use bold typography to establish hierarchy.
* Use a monospace font for terminal-style elements and technical values.
* Avoid using uppercase for long paragraphs.

Suggested font pairing:

```css
font-family: "Montserrat", sans-serif;
```

For terminal elements:

```css
font-family: "JetBrains Mono", monospace;
```

## 2.3. Shapes and Graphic Language

### Primary Shape: Hexagonal Insignia

The Born2beroot identity may be represented through a hexagonal badge with:

* A double neon-cyan border.
* A deep navy interior.
* Strong, clean outlines.
* A compact composition suitable for a logo or decorative hero element.

The insignia should act as a recognizable brand element, not as the container for the entire landing page.

### Illustration Style

Sticker-like vector illustration inspired by space exploration.

Visual characteristics:

* Thick, defined outlines in dark blue.
* Flat colors with minimal shading.
* Simple highlights and four-point stars.
* Rounded, friendly shapes.
* A small number of carefully placed decorative details.

### Main Illustration

A chibi-style astronaut using a laptop.

Illustration details:

* White spacesuit.
* Blue visor or screen.
* Cyan highlights.
* Laptop featuring a small rocket graphic.
* Coral-red accents on the rocket or laptop.
* Dark outlines to separate the illustration from the background.

The illustration should complement the technical content without competing with the main heading.

---

# 3. Information Architecture

The page consists of five main sections:

1. Header and system status.
2. Hero introduction.
3. Services and project links.
4. Technical overview.
5. Footer.

The page should be a single, vertically scrollable landing page.

No routing framework, client-side application, or database is required.

---

# 4. Component Specifications

## 4.1. Header

### Purpose

Identify the server and provide a quick visual indication of its status.

### Layout

* Left: hostname or compact brand mark.
* Right: operating system label and status indicator.
* Optional thin cyan divider below the header.

### Content

Brand:

`iualkhim42`

System label:

`DEBIAN 13 · TRIXIE`

Status:

`SERVER ONLINE`

### Visual Treatment

* Transparent or dark navy background.
* Small cyan status dot.
* White hostname.
* Gray or white technical metadata.
* Minimal borders and spacing.

### Behavior

The header should remain static at the top of the page. A sticky header is optional and should only be added if it improves navigation.

**Important:** The status label is initially a visual label, not a live health check. It must not imply that every service is operational unless its status is actually verified.

---

## 4.2. Hero Section

### Purpose

Introduce the project and establish its visual identity.

### Layout

Desktop:

* Left column: heading, description, and primary action.
* Right column: astronaut illustration or hexagonal insignia.

Mobile:

* Stack the content vertically.
* Display the illustration below the heading or between the description and actions.

### Copy

Eyebrow:

`42 / SYSTEM ADMINISTRATION`

Main heading:

`Welcome to`

Brand heading:

`iualkhim42.`

Tagline:

`A small server. A lot going on.`

Description:

`Born2beroot is a system administration project focused on building a secure Linux environment from the ground up. This server is my playground for virtualization, networking, security and automation.`

Primary action:

`EXPLORE THE SERVICES`

Secondary action:

`VIEW SOURCE CODE`

### Visual Treatment

* Large, bold typography.
* White main heading.
* Cyan hostname or highlighted words.
* Comfortable line spacing.
* Space-themed illustration.
* Subtle background stars or radial light effects.

### Behavior

The primary action scrolls to the services section.

The secondary action opens the configured GitHub repository.

---

## 4.3. Services Section

### Section Heading

`Explore the setup`

### Supporting Text

`A closer look at the services running on this machine.`

### Layout

Three cards displayed in a responsive grid.

Each card contains:

* An icon or small illustration.
* Service name.
* Short description.
* Link label.
* Optional arrow indicating navigation.

### Card 1 — WordPress

**Title:**

`WordPress`

**Description:**

`A self-hosted website running on my server.`

**Action:**

`EXPLORE WEBSITE ↗`

**Destination:**

The configured WordPress URL.

**Icon direction:**

A simple CMS or website symbol. A recognizable WordPress icon may be used if desired.

### Card 2 — n8n

**Title:**

`n8n`

**Description:**

`Automated workflows and event-driven tasks.`

**Action:**

`EXPLORE WORKFLOWS ↗`

**Destination:**

The configured n8n editor URL.

**Icon direction:**

A connected-node or workflow symbol.

### Card 3 — GitHub

**Title:**

`GitHub`

**Description:**

`Source code, configuration and project documentation.`

**Action:**

`VIEW REPOSITORY ↗`

**Destination:**

The actual Born2beroot GitHub repository URL.

**Icon direction:**

A Git branch or repository symbol.

### Card Styling

* Deep navy background.
* Thin, subtle border.
* Cyan border or highlight on hover.
* White titles.
* Gray descriptions.
* Cyan action links.
* Consistent padding and card heights.
* Small coral accents may be used sparingly.

### Interaction

* Entire card may be clickable, provided its accessible link behavior remains clear.
* Hover transitions should be subtle.
* Keyboard focus must be clearly visible.
* External links should communicate that they navigate away from the landing page.

---

## 4.4. Technical Overview

### Section Heading

`Under the hood`

### Supporting Text

`The essentials behind this little machine.`

### Content

Display the following information as compact metadata rows or small technical badges.

| Property         | Value              |
| ---------------- | ------------------ |
| Operating System | Debian 13 (Trixie) |
| Web Server       | Lighttpd           |
| Remote Access    | SSH                |
| Firewall         | UFW                |
| Storage          | LVM                |
| Automation       | n8n                |

### Visual Treatment

* Compact layout with clear labels.
* Monospace values are encouraged.
* Muted gray labels and white values.
* Cyan separators or small status indicators.
* Avoid oversized cards that repeat information already presented in the hero.

### Accuracy Requirements

The displayed information must reflect the actual VM configuration.

If a property changes, the documentation and landing page should be updated accordingly.

The landing page does not need to query the operating system dynamically. The initial version can use static HTML.

---

## 4.5. Footer

### Content

`Built as part of 42 Born2beroot`

Secondary line:

`BUILT WITH CURIOSITY · POWERED BY LINUX`

Optional links:

* GitHub repository.
* Project documentation.

### Visual Treatment

* Small typography.
* Muted gray text.
* Thin top border.
* Centered or left-aligned content.
* A small cyan star or status indicator.

The footer should feel like a quiet closing detail rather than another major section.

---

# 5. Layout & Responsive Behavior

## 5.1. General Layout

* Single-page structure.
* Centered content container.
* Consistent horizontal padding.
* Clear vertical spacing between sections.
* Maximum content width of approximately 1100–1200 px.
* Full-page dark background.

## 5.2. Desktop

* Horizontal header.
* Two-column hero.
* Three-column services grid.
* Compact technical overview.
* Balanced negative space around the illustration.

## 5.3. Tablet

* Preserve the two-column hero when space allows.
* Reduce heading sizes and card gaps.
* Keep service cards readable.

## 5.4. Mobile

* Stack hero content vertically.
* Use a single-column services grid.
* Allow technical metadata to wrap cleanly.
* Keep navigation links accessible.
* Prevent horizontal overflow.
* Reduce decorative elements if they crowd the content.

---

# 6. Technical Specification

## 6.1. Technology Stack

* HTML5.
* CSS3.
* Lighttpd.
* Optional SVG assets.
* Optional Google Fonts.

No JavaScript is required for the initial implementation.

No frontend framework, package manager, or build process is necessary.

## 6.2. File Structure

```text
/var/www/html/
├── index.html
├── css/
│   └── style.css
└── assets/
    ├── astronaut.svg
    └── favicon.svg
```

The astronaut illustration and favicon are optional assets. If no illustration is available, the hero can use a CSS-built hexagonal badge or a simple typographic composition.

## 6.3. CSS Organization

The stylesheet should define reusable design tokens using CSS custom properties.

Example:

```css
:root {
    --color-cyan: #00C2FF;
    --color-blue: #00A3E0;
    --color-space: #0A113B;
    --color-navy: #0F1A52;
    --color-gray: #7A84A5;
    --color-white: #FFFFFF;
    --color-coral: #E63946;

    --font-primary: "Montserrat", sans-serif;
    --font-mono: "JetBrains Mono", monospace;

    --content-width: 1200px;
    --radius-card: 12px;
}
```

These variables should be reused throughout the stylesheet to maintain visual consistency.

## 6.4. Link Configuration

The following destinations must be configured before deployment:

| Service   | Configuration                            |
| --------- | ---------------------------------------- |
| WordPress | Actual URL of the WordPress installation |
| n8n       | Actual URL of the n8n editor             |
| GitHub    | URL of the Born2beroot repository        |

During local development, the known service ports are:

* WordPress: port `80`.
* n8n: port `5678`.
* SSH: port `4242`.

The correct browser URLs depend on how the VM's network interfaces and port forwarding are configured.

Do not assume that `localhost` refers to the VM when opening the landing page from the host computer.

---

# 7. Accessibility & Usability

* Use semantic HTML elements: `header`, `main`, `section`, `article`, and `footer`.
* Maintain sufficient text/background contrast.
* Use descriptive link text.
* Provide visible keyboard focus indicators.
* Include meaningful `alt` text for informative illustrations.
* Use empty `alt` attributes for purely decorative images.
* Respect reduced-motion preferences.
* Avoid relying exclusively on color to communicate status.
* Keep body text comfortably readable.

---

# 8. Performance & Security

* Keep the page lightweight and avoid unnecessary dependencies.
* Prefer optimized SVG illustrations over large raster images.
* Avoid autoplay animations and unnecessary JavaScript.
* Use HTTPS for external destinations where supported.
* Do not expose passwords, tokens, private configuration, or sensitive server information.
* Do not publish internal IP addresses unless they are intentionally needed for the intended environment.
* Do not display live service status unless it is actually verified.

The landing page should not weaken the existing firewall, SSH, or web-server configuration.

---

# 9. Implementation Plan

## Phase 1 — Structure

* [ ] Create the HTML document.
* [ ] Add the header and hero.
* [ ] Add the services section.
* [ ] Add the technical overview.
* [ ] Add the footer.

## Phase 2 — Visual Design

* [ ] Define CSS custom properties.
* [ ] Configure typography.
* [ ] Implement the space-themed background.
* [ ] Style service cards and interactive states.
* [ ] Add the astronaut illustration or hexagonal badge.
* [ ] Add responsive layouts.

## Phase 3 — Integration

* [ ] Configure the WordPress link.
* [ ] Configure the n8n link.
* [ ] Configure the GitHub link.
* [ ] Verify the landing page through Lighttpd.

## Phase 4 — Testing

* [ ] Test the page in a desktop browser.
* [ ] Test the layout on a narrow viewport.
* [ ] Verify all navigation links.
* [ ] Check browser console errors.
* [ ] Verify CSS and asset loading.
* [ ] Confirm that the page remains accessible and readable.
* [ ] Ensure no sensitive server information is exposed.

---

# 10. Definition of Done

The landing page is complete when:

* The page loads correctly through Lighttpd.
* The visual identity consistently follows the defined color palette and typography.
* All five main sections are implemented.
* WordPress, n8n, and GitHub links point to their intended destinations.
* The layout adapts to desktop and mobile screens.
* The implementation does not require a frontend framework.
* The content accurately represents the Born2beroot environment.
* The page introduces the project clearly while maintaining a distinctive space-themed identity.

**Final design principle:** Make the server feel like a small space station: a recognizable identity, a clear mission, and a few well-organized services ready to explore.
