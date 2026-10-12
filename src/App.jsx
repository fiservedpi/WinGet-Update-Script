import { useMemo, useState } from 'react';

const templates = [
  {
    id: 'startup',
    name: 'Startup Launch',
    tag: 'SaaS / Product',
    accent: '#6d5efc',
    background: '#f4f7ff',
    secondary: '#0f172a',
    description: 'Modern product launch page with bold callouts and conversion sections.',
    stats: ['50K users', '12 launches', '4.9 rating'],
  },
  {
    id: 'portfolio',
    name: 'Creative Portfolio',
    tag: 'Personal Brand',
    accent: '#ff6b6b',
    background: '#fff7f4',
    secondary: '#1f2937',
    description: 'Clean personal brand layout for freelancers, creatives, and agencies.',
    stats: ['12 projects', '8 years', '3x growth'],
  },
  {
    id: 'studio',
    name: 'Studio Showcase',
    tag: 'Design Agency',
    accent: '#10b981',
    background: '#edfdf7',
    secondary: '#11212d',
    description: 'Polished agency experience with work samples and feature blocks.',
    stats: ['34 clients', '102 wins', '7 cities'],
  },
  {
    id: 'app',
    name: 'App Promo',
    tag: 'Mobile / Tech',
    accent: '#0ea5e9',
    background: '#f0f9ff',
    secondary: '#111827',
    description: 'Performance-driven app landing page to highlight product features.',
    stats: ['2.4M installs', '99.9% uptime', '24/7 support'],
  },
];

const sampleSections = [
  { label: 'Hero', visible: true },
  { label: 'Features', visible: true },
  { label: 'Testimonials', visible: true },
  { label: 'Pricing', visible: false },
  { label: 'FAQ', visible: true },
];

function App() {
  const [selectedId, setSelectedId] = useState('startup');
  const [pageTitle, setPageTitle] = useState('Launch your next big idea');
  const [primaryColor, setPrimaryColor] = useState('#6d5efc');
  const [bgColor, setBgColor] = useState('#f4f7ff');
  const [textColor, setTextColor] = useState('#0f172a');
  const [ctaText, setCtaText] = useState('Get Started');

  const selectedTemplate = useMemo(
    () => templates.find((template) => template.id === selectedId) ?? templates[0],
    [selectedId]
  );

  const previewStyle = {
    '--page-bg': bgColor,
    '--brand': primaryColor,
    '--text': textColor,
    '--muted': '#64748b',
  };

  const applyTemplate = (template) => {
    setSelectedId(template.id);
    setPrimaryColor(template.accent);
    setBgColor(template.background);
    setTextColor(template.secondary);
  };

  const selectedSummary = useMemo(
    () => `${selectedTemplate.name} • ${selectedTemplate.tag}`,
    [selectedTemplate]
  );

  return (
    <div className="app-shell" style={previewStyle}>
      <aside className="sidebar">
        <div className="brand-block">
          <div className="brand-mark">P</div>
          <div>
            <p className="eyebrow">Builder</p>
            <h1>Page Picker</h1>
          </div>
        </div>

        <div className="panel">
          <p className="panel-label">Templates</p>
          <div className="template-list">
            {templates.map((template) => (
              <button
                key={template.id}
                type="button"
                className={`template-card ${selectedId === template.id ? 'active' : ''}`}
                onClick={() => applyTemplate(template)}
              >
                <span className="template-swatch" style={{ background: template.accent }} />
                <div>
                  <strong>{template.name}</strong>
                  <small>{template.tag}</small>
                </div>
              </button>
            ))}
          </div>
        </div>

        <div className="panel">
          <p className="panel-label">Theme</p>
          <div className="picker-grid">
            <label>
              <span>Background</span>
              <input type="color" value={bgColor} onChange={(e) => setBgColor(e.target.value)} />
            </label>
            <label>
              <span>Accent</span>
              <input type="color" value={primaryColor} onChange={(e) => setPrimaryColor(e.target.value)} />
            </label>
            <label>
              <span>Text</span>
              <input type="color" value={textColor} onChange={(e) => setTextColor(e.target.value)} />
            </label>
          </div>
        </div>

        <div className="panel">
          <p className="panel-label">Content</p>
          <div className="content-stack">
            <label>
              <span>Headline</span>
              <input value={pageTitle} onChange={(e) => setPageTitle(e.target.value)} />
            </label>
            <label>
              <span>Button text</span>
              <input value={ctaText} onChange={(e) => setCtaText(e.target.value)} />
            </label>
          </div>
        </div>
      </aside>

      <main className="preview-panel">
        <div className="preview-header">
          <div>
            <p className="eyebrow">Selected layout</p>
            <h2>{selectedSummary}</h2>
          </div>
          <button type="button" className="primary-action">
            {ctaText}
          </button>
        </div>

        <div className="page-preview" style={{ background: bgColor, color: textColor }}>
          <header className="topbar">
            <div className="logo-wrap">
              <span className="logo-dot" style={{ background: primaryColor }} />
              <span>Northstar</span>
            </div>
            <nav>
              <a href="#">Product</a>
              <a href="#">Solutions</a>
              <a href="#">Pricing</a>
            </nav>
            <button type="button" className="nav-button" style={{ background: primaryColor, color: '#ffffff' }}>
              {ctaText}
            </button>
          </header>

          <section className="hero-section">
            <div className="hero-copy">
              <span className="badge" style={{ background: `${primaryColor}1A`, color: primaryColor }}>
                {selectedTemplate.tag}
              </span>
              <h3>{pageTitle}</h3>
              <p>
                Build beautiful, conversion-focused pages faster with curated templates, rich sections,
                and polished color systems.
              </p>
              <div className="cta-row">
                <button type="button" style={{ background: primaryColor, color: '#fff' }}>
                  {ctaText}
                </button>
                <button type="button" className="ghost-button">
                  View demo
                </button>
              </div>
              <div className="stats-row">
                {selectedTemplate.stats.map((stat) => (
                  <div key={stat} className="stat-pill">
                    {stat}
                  </div>
                ))}
              </div>
            </div>
            <div className="hero-card" style={{ borderColor: `${primaryColor}50` }}>
              <div className="card-window">
                <div className="mini-chart">
                  <span style={{ background: primaryColor }} />
                  <span style={{ background: primaryColor, opacity: 0.7 }} />
                  <span style={{ background: primaryColor, opacity: 0.5 }} />
                  <span style={{ background: primaryColor, opacity: 0.3 }} />
                </div>
                <div className="mini-metrics">
                  <div>
                    <small>Engagement</small>
                    <strong>87%</strong>
                  </div>
                  <div>
                    <small>Conversion</small>
                    <strong>+24%</strong>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <section className="feature-section">
            {sampleSections.map((section) => (
              <div key={section.label} className={`feature-box ${section.visible ? 'visible' : 'muted'}`}>
                <span className="feature-icon" style={{ background: `${primaryColor}1A`, color: primaryColor }}>
                  {section.label[0]}
                </span>
                <h4>{section.label}</h4>
                <p>Flexible block to support your content priorities and visual rhythm.</p>
              </div>
            ))}
          </section>
        </div>
      </main>
    </div>
  );
}

export default App;
