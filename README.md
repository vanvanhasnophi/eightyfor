# EightyFor - Personal Portfolio

A modern personal portfolio website built with Vue.js and designed with a sleek dark theme.

## 🌟 Features

- **Dark Theme Design**: Modern, eye-catching dark theme with cyan and pink accent colors
- **Responsive Layout**: Fully responsive design that works on all devices
- **Smooth Animations**: Elegant hover effects and transitions
- **Modern Stack**: Built with Vue 3 and Vite for optimal performance
- **Clean Code**: Well-structured components following Vue.js best practices

## 🎨 Sections

- **Hero**: Eye-catching introduction with gradient text effects
- **About**: Professional background and description
- **Skills**: Showcase of technical skills and expertise
- **Projects**: Featured projects with tags and links
- **Contact**: Social media links and contact information

## 🚀 Getting Started

### Prerequisites

- Node.js (v20.19.0 or higher)
- npm (v10.8.2 or higher)

### Installation

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 🛠️ Technology Stack

- **Frontend Framework**: Vue.js 3.5
- **Build Tool**: Vite 7.1
- **Styling**: CSS3 with CSS Variables
- **Icons**: Unicode Emoji

## 📦 Project Structure

```
eightyfor/
├── src/
│   ├── assets/          # CSS and static assets
│   ├── components/      # Vue components
│   │   ├── Header.vue
│   │   ├── Hero.vue
│   │   ├── About.vue
│   │   ├── Skills.vue
│   │   ├── Projects.vue
│   │   ├── Contact.vue
│   │   └── Footer.vue
│   ├── App.vue         # Main app component
│   └── main.js         # Application entry point
├── public/             # Public static assets
├── index.html          # HTML entry point
└── vite.config.js      # Vite configuration
```

## 🎨 Customization

To customize the site for your own use:

1. Update personal information in `src/components/Hero.vue`
2. Modify skills in `src/components/Skills.vue`
3. Add your projects in `src/components/Projects.vue`
4. Update contact links in `src/components/Contact.vue`
5. Customize colors in `src/assets/base.css` (CSS variables)

## Recommended IDE Setup

[VS Code](https://code.visualstudio.com/) + [Vue (Official)](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (and disable Vetur).

## Recommended Browser Setup

- Chromium-based browsers (Chrome, Edge, Brave, etc.):
  - [Vue.js devtools](https://chromewebstore.google.com/detail/vuejs-devtools/nhdogjmejiglipccpnnnanhbledajbpd) 
  - [Turn on Custom Object Formatter in Chrome DevTools](http://bit.ly/object-formatters)
- Firefox:
  - [Vue.js devtools](https://addons.mozilla.org/en-US/firefox/addon/vue-js-devtools/)
  - [Turn on Custom Object Formatter in Firefox DevTools](https://fxdx.dev/firefox-devtools-custom-object-formatters/)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
