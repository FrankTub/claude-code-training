// Gedeelde componenten voor alle lessen: quiz en surface-tabs.
//
// Quiz:
//   <fieldset class="quiz" data-answer="1">        (index van het juiste antwoord, vanaf 0)
//     <legend>Vraag 1</legend>
//     <p class="q">Vraagtekst</p>
//     <button class="opt">Antwoord A</button> ...
//     <p class="why">Uitleg, getoond na een keuze.</p>
//   </fieldset>
//   <p class="score" data-quiz-score></p>             (optioneel: totaalscore)
//
// Surface-tabs (CLI / VS Code / Desktop):
//   <div class="surfaces">
//     <div class="surface-panel" data-surface="CLI">...</div>
//     <div class="surface-panel" data-surface="VS Code">...</div>
//   </div>
//   Keuze wordt per bezoeker onthouden in localStorage.
(function () {
  function store(key, val) {
    try { if (val === undefined) return localStorage.getItem(key); localStorage.setItem(key, val); } catch (e) { return null; }
  }

  function initQuizzes() {
    const quizzes = Array.from(document.querySelectorAll('.quiz'));
    const scoreEl = document.querySelector('[data-quiz-score]');
    let answered = 0, correct = 0;
    const updateScore = () => {
      if (scoreEl) scoreEl.textContent = answered === quizzes.length
        ? `Score: ${correct} van ${quizzes.length} goed bij eerste poging.`
        : `${answered} van ${quizzes.length} beantwoord.`;
    };
    quizzes.forEach((quiz) => {
      const answer = Number(quiz.dataset.answer);
      const opts = Array.from(quiz.querySelectorAll('button.opt'));
      const why = quiz.querySelector('.why');
      if (why) why.hidden = true;
      let first = true;
      opts.forEach((btn, i) => {
        btn.type = 'button';
        btn.addEventListener('click', () => {
          if (i === answer) {
            btn.classList.add('right');
            opts.forEach((b) => (b.disabled = true));
            if (why) why.hidden = false;
            answered++; if (first) correct++;
            updateScore();
          } else {
            btn.classList.add('wrong');
            btn.disabled = true;
            first = false;
          }
        });
      });
    });
    updateScore();
  }

  function initSurfaces() {
    const saved = store('cc-surface');
    document.querySelectorAll('.surfaces').forEach((group) => {
      const panels = Array.from(group.querySelectorAll('.surface-panel'));
      const bar = document.createElement('div');
      bar.className = 'surface-tabs';
      bar.setAttribute('role', 'tablist');
      const select = (name) => {
        panels.forEach((p) => (p.hidden = p.dataset.surface !== name));
        bar.querySelectorAll('button').forEach((b) => b.setAttribute('aria-selected', String(b.textContent === name)));
      };
      panels.forEach((p) => {
        const b = document.createElement('button');
        b.type = 'button'; b.setAttribute('role', 'tab'); b.textContent = p.dataset.surface;
        b.addEventListener('click', () => {
          store('cc-surface', p.dataset.surface);
          document.querySelectorAll('.surfaces').forEach((g) => g.dispatchEvent(new CustomEvent('surface', { detail: p.dataset.surface })));
        });
        bar.appendChild(b);
      });
      group.addEventListener('surface', (e) => {
        if (panels.some((p) => p.dataset.surface === e.detail)) select(e.detail);
      });
      group.prepend(bar);
      const start = panels.find((p) => p.dataset.surface === saved) || panels[0];
      select(start.dataset.surface);
    });
  }

  document.addEventListener('DOMContentLoaded', () => { initQuizzes(); initSurfaces(); });
})();
