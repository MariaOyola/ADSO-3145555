  // ─── THEME TOGGLE ───
  const themeToggle = document.getElementById('themeToggle');
  const toggleIcon  = document.getElementById('toggleIcon');
  const toggleLabel = document.getElementById('toggleLabel');
  const html = document.documentElement;

  if (localStorage.getItem('theme') === 'light') {
    html.classList.add('light');
    toggleIcon.textContent  = '☀️';
    toggleLabel.textContent = 'Claro';
  }

  themeToggle.addEventListener('click', () => {
    const isLight = html.classList.toggle('light');
    toggleIcon.textContent  = isLight ? '☀️' : '🌙';
    toggleLabel.textContent = isLight ? 'Claro' : 'Oscuro';
    localStorage.setItem('theme', isLight ? 'light' : 'dark');
  });

  // ─── TALLER STATE ───
  let currentTaller = null; // 't1' or 't2'

  const welcomeScreen = document.getElementById('welcome-screen');
  const mainLayout    = document.getElementById('main-layout');
  const backBtn       = document.getElementById('backToHome');
  const t1Content     = document.getElementById('t1-content');
  const t2Content     = document.getElementById('t2-content');
  const t2Nav         = document.getElementById('t2-nav');
  const hamburger     = document.getElementById('hamburger');

  // Sidebar text elements
  const sbTag      = document.getElementById('sb-tag');
  const sbTitle    = document.getElementById('sb-title');
  const sbSubtitle = document.getElementById('sb-subtitle');
  const sbBadge    = document.getElementById('sb-badge');

  // Hero elements
  const heroEyebrow = document.getElementById('hero-eyebrow-text');
  const heroH1      = document.getElementById('hero-h1');
  const heroTaller  = document.getElementById('hero-meta-taller');
  const heroPuntos  = document.getElementById('hero-meta-puntos');
  const heroStatus  = document.getElementById('hero-meta-status');

  const progressFill = document.getElementById('progress-fill');
  const progressPct  = document.getElementById('progress-pct');

  // T1 config
  const t1Config = {
    sbTag: 'Taller #01', sbTitle: 'Interpretar Informe de Diseño',
    sbSubtitle: 'Análisis · Arquitectura · Implementación', sbBadge: '11 puntos',
    eyebrow: 'Análisis de software',
    h1: 'Interpretar<br/><span>Informe</span> de Diseño',
    metaTaller: 'Taller 01', metaPuntos: '11 puntos', metaStatus: 'Completado',
    completed: new Set([1,2,3,4,5,6,7,8,9,10,11]), total: 11,
    defaultSection: 'home'
  };

  // T2 config (will grow as content is added)
  const t2Config = {
    sbTag: 'Taller #02', sbTitle: 'Seleccionar Herramientas de Desarrollo',
    sbSubtitle: 'Evaluación · Selección · Justificación', sbBadge: 'En progreso',
    eyebrow: 'Herramientas de desarrollo',
    h1: 'Seleccionar<br/><span>Herramientas</span> de Desarrollo',
    metaTaller: 'Taller 02', metaPuntos: 'En progreso', metaStatus: 'En progreso',
    completed: new Set([1,2,3,4,5]), total: 7,
    defaultSection: 't2-home'
  };

  function enterTaller(tallerKey) {
    currentTaller = tallerKey;
    const cfg = tallerKey === 't1' ? t1Config : tallerKey === 't2' ? t2Config : t3Config;

    sbTag.textContent      = cfg.sbTag;
    sbTitle.textContent    = cfg.sbTitle;
    sbSubtitle.textContent = cfg.sbSubtitle;
    sbBadge.textContent    = cfg.sbBadge;

    heroEyebrow.textContent = cfg.eyebrow;
    heroH1.innerHTML        = cfg.h1;
    heroTaller.textContent  = cfg.metaTaller;
    heroPuntos.textContent  = cfg.metaPuntos;
    heroStatus.textContent  = cfg.metaStatus;

    const t1NavItems = document.querySelectorAll('nav > a.nav-item, nav > .nav-section-label');
    t1NavItems.forEach(el => el.style.display = tallerKey === 't1' ? '' : 'none');
    t2Nav.style.display   = tallerKey === 't2' ? 'block' : 'none';
    document.getElementById('t3-nav').style.display = tallerKey === 't3' ? 'block' : 'none';

    t1Content.style.display = tallerKey === 't1' ? 'block' : 'none';
    t2Content.style.display = tallerKey === 't2' ? 'block' : 'none';
    document.getElementById('t3-content').style.display = tallerKey === 't3' ? 'block' : 'none';

    document.body.classList.remove('taller2-active', 'taller3-active');
    if (tallerKey === 't2') document.body.classList.add('taller2-active');
    if (tallerKey === 't3') document.body.classList.add('taller3-active');

    updateProgress(cfg);
    showSection(cfg.defaultSection);

    welcomeScreen.classList.add('hiding');
    setTimeout(() => {
      welcomeScreen.classList.add('hidden');
      mainLayout.style.display = 'flex';
      backBtn.style.display = 'flex';
      hamburger.style.display = '';
    }, 480);
  }

  function backToWelcome() {
    welcomeScreen.classList.remove('hidden');
    requestAnimationFrame(() => welcomeScreen.classList.remove('hiding'));
    mainLayout.style.display = 'none';
    backBtn.style.display = 'none';
    currentTaller = null;
  }

  const t3Config = {
    sbTag: 'Taller #03', sbTitle: 'Configurar Herramientas de Desarrollo',
    sbSubtitle: 'Instalación · Configuración · Verificación', sbBadge: '2 puntos',
    eyebrow: 'Configuración del entorno',
    h1: 'Configurar<br/><span>Herramientas</span> de Desarrollo',
    metaTaller: 'Taller 03', metaPuntos: '2 puntos', metaStatus: 'Completado',
    completed: new Set([1,2]), total: 2,
    defaultSection: 't3-home'
  };

  // Welcome screen buttons
  document.getElementById('wl-btn-t1').addEventListener('click', () => enterTaller('t1'));
  document.getElementById('wl-btn-t2').addEventListener('click', () => enterTaller('t2'));
  document.getElementById('wl-btn-t3').addEventListener('click', () => enterTaller('t3'));
  backBtn.addEventListener('click', backToWelcome);

  // ─── SECTION NAVIGATION ───
  function showSection(target) {
    document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));

    const targetSection = document.getElementById(target);
    if (targetSection) targetSection.classList.add('active');

    const activeNav = document.querySelector(`.nav-item[data-target="${target}"]`);
    if (activeNav) activeNav.classList.add('active');

    const cfg = currentTaller === 't1' ? t1Config : currentTaller === 't2' ? t2Config : t3Config;
    updateProgress(cfg);
  }

  document.querySelectorAll('.nav-item, .point-card').forEach(item => {
    item.addEventListener('click', e => {
      e.preventDefault();
      const target = item.dataset.target;
      if (target) showSection(target);
      if (window.innerWidth <= 768) {
        document.getElementById('sidebar').classList.remove('open');
      }
    });
  });

  function updateProgress(cfg) {
    if (!cfg || cfg.total === 0) {
      progressFill.style.width = '0%';
      progressPct.textContent = '0 / 0';
      return;
    }
    const done = cfg.completed.size;
    const pct  = Math.round((done / cfg.total) * 100);
    progressFill.style.width = pct + '%';
    progressPct.textContent  = `${done} / ${cfg.total}`;
  }

  // ─── HAMBURGER ───
  hamburger.addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('open');
  });
