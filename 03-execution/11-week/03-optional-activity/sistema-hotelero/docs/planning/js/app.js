(function () {
  "use strict";

  var STORAGE_KEY = "planning_board_state_v1";
  var COLUMN_ORDER = [
    "Backlog",
    "Ready",
    "DoR",
    "In Progress",
    "Review",
    "Testing",
    "DoD",
    "Deploy",
    "Done",
    "Blocked",
    "Accepted"
  ];

  var state = {
    moscow: null,
    designThinking: null,
    userStories: null,
    timeline: null,
    initialBoardItems: [],
    boardItems: []
  };

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  function clone(value) {
    return JSON.parse(JSON.stringify(value));
  }

  function loadJson(path) {
    return fetch(path).then(function (response) {
      if (!response.ok) {
        throw new Error("No se pudo cargar " + path);
      }
      return response.json();
    });
  }

  function fallbackData() {
    return {
      moscow: {
        projectName: "Sistema de hoteleria",
        source: "docs/architecture/model-data/es",
        mustHave: [
          { id: "M-001", item: "Consultar catalogo y disponibilidad de habitacion", source: "Prestacion de servicio", inferido: false },
          { id: "M-002", item: "Crear y administrar reserva", source: "Prestacion de servicio", inferido: false },
          { id: "M-003", item: "Check in y check out con actualizacion de estado", source: "Flujo core", inferido: false }
        ],
        shouldHave: [
          { id: "S-001", item: "Control de inventario y disponibilidad", source: "Inventario", inferido: false },
          { id: "S-002", item: "Seguridad por rol y permiso", source: "Seguridad", inferido: false }
        ],
        couldHave: [
          { id: "C-001", item: "Promocion y fidelizacion", source: "Notificacion", inferido: false }
        ],
        wontHaveNow: [
          {
            id: "W-001",
            item: "Integracion con pasarela de pago",
            source: "Pendiente por confirmar",
            inferido: false,
            note: "No esta en architecture"
          }
        ]
      },
      designThinking: {
        phases: [
          {
            id: "DT-01",
            name: "Empatizar",
            objective: "Comprender dolores operativos del hotel.",
            findings: ["Operacion requiere centralizacion.", "Se necesita trazabilidad de estados y pagos."],
            guideQuestions: ["Que tareas son manuales hoy?", "Que actores necesitan visibilidad inmediata?"],
            risksOrGaps: ["No esta en architecture el listado oficial de roles."],
            expectedOutcome: "Mapa de necesidades y actores priorizados."
          },
          {
            id: "DT-02",
            name: "Definir",
            objective: "Delimitar alcance inicial del flujo core.",
            findings: ["Core: disponibilidad -> reserva -> estadia -> facturacion."],
            guideQuestions: ["Que minimo habilita una estadia completa?"],
            risksOrGaps: ["No esta en architecture la politica de cancelacion."],
            expectedOutcome: "Alcance inicial validable."
          }
        ]
      },
      userStories: {
        stories: [
          {
            id: "HU-001",
            title: "Consultar disponibilidad de habitacion",
            role: "Cliente",
            description: "Como cliente, quiero consultar disponibilidad de habitacion por fecha, para elegir una opcion real antes de reservar.",
            acceptanceCriteria: ["Muestra habitaciones disponibles por fecha.", "Evita habitaciones bloqueadas o en mantenimiento."],
            moscowPriority: "Must Have",
            estimate: 5,
            estimateJustification: "Cruza estado de habitacion y rango de fechas.",
            initialStatus: "Backlog",
            dependencies: [],
            observations: "Estados oficiales completos No estan en architecture."
          },
          {
            id: "HU-002",
            title: "Crear reserva de habitacion",
            role: "Empleado de recepcion",
            description: "Como empleado de recepcion, quiero crear una reserva, para asegurar la estadia futura del cliente.",
            acceptanceCriteria: ["Asocia cliente, habitacion y fechas.", "Evita doble reserva."],
            moscowPriority: "Must Have",
            estimate: 8,
            estimateJustification: "Requiere validaciones de solapamiento.",
            initialStatus: "Backlog",
            dependencies: ["HU-001"],
            observations: "Politica de cancelacion No esta en architecture."
          }
        ],
        boardExtras: [
          {
            id: "RSK-001",
            title: "Estados oficiales no definidos",
            moscowPriority: "Must Have",
            estimate: 8,
            initialStatus: "Blocked",
            type: "Riesgo",
            note: "No esta en architecture: estados oficiales por proceso."
          }
        ]
      },
      timeline: {
        rows: [
          {
            id: "HU-001",
            activity: "Consultar disponibilidad de habitacion",
            priority: "Must Have",
            estimate: 5,
            designThinkingPhase: "Empatizar",
            suggestedWeek: "Semana 1",
            dependencies: "Sin dependencia",
            suggestedOwner: "Frontend",
            expectedDeliverable: "Consulta de disponibilidad por fecha",
            status: "Backlog"
          },
          {
            id: "HU-002",
            activity: "Crear reserva de habitacion",
            priority: "Must Have",
            estimate: 8,
            designThinkingPhase: "Definir",
            suggestedWeek: "Semana 2",
            dependencies: "HU-001",
            suggestedOwner: "Backend",
            expectedDeliverable: "Flujo de reserva con control de solapamiento",
            status: "Backlog"
          }
        ]
      }
    };
  }

  function renderMoscow(data) {
    var grid = document.getElementById("moscowGrid");
    var columns = [
      { key: "mustHave", title: "Must Have" },
      { key: "shouldHave", title: "Should Have" },
      { key: "couldHave", title: "Could Have" },
      { key: "wontHaveNow", title: "Won't Have por ahora" }
    ];

    grid.innerHTML = columns
      .map(function (column) {
        var items = data[column.key] || [];
        var list = items
          .map(function (item) {
            var badgeClass = item.inferido ? "inferido" : "confirmado";
            var badgeLabel = item.inferido ? "Inferido" : "Confirmado";
            return (
              "<li>" +
              "<strong>" + escapeHtml(item.id) + "</strong> - " +
              escapeHtml(item.item) +
              "<div><span class=\"badge " + badgeClass + "\">" + badgeLabel + "</span></div>" +
              "<small>Fuente: " + escapeHtml(item.source || "No especificada") + "</small>" +
              (item.note ? "<div><small>Nota: " + escapeHtml(item.note) + "</small></div>" : "") +
              "</li>"
            );
          })
          .join("");

        return (
          "<article class=\"card moscow-column\">" +
          "<h3>" + escapeHtml(column.title) + "</h3>" +
          "<ul>" + list + "</ul>" +
          "</article>"
        );
      })
      .join("");
  }

  function renderDesignThinking(data) {
    var grid = document.getElementById("designThinkingGrid");

    grid.innerHTML = (data.phases || [])
      .map(function (phase) {
        return (
          "<article class=\"card\">" +
          "<h3>" + escapeHtml(phase.name) + "</h3>" +
          "<p><strong>Objetivo:</strong> " + escapeHtml(phase.objective) + "</p>" +
          "<p><strong>Hallazgos:</strong></p><ul>" +
          phase.findings.map(function (v) { return "<li>" + escapeHtml(v) + "</li>"; }).join("") +
          "</ul>" +
          "<p><strong>Preguntas guia:</strong></p><ul>" +
          phase.guideQuestions.map(function (v) { return "<li>" + escapeHtml(v) + "</li>"; }).join("") +
          "</ul>" +
          "<p><strong>Riesgos o vacios:</strong></p><ul>" +
          phase.risksOrGaps.map(function (v) { return "<li>" + escapeHtml(v) + "</li>"; }).join("") +
          "</ul>" +
          "<p><strong>Resultado esperado:</strong> " + escapeHtml(phase.expectedOutcome) + "</p>" +
          "</article>"
        );
      })
      .join("");
  }

  function renderStoriesTable(stories) {
    var body = document.getElementById("storiesTableBody");
    body.innerHTML = stories
      .map(function (story) {
        return (
          "<tr>" +
          "<td>" + escapeHtml(story.id) + "</td>" +
          "<td>" + escapeHtml(story.title) + "</td>" +
          "<td>" + escapeHtml(story.role) + "</td>" +
          "<td>" + escapeHtml(story.description) + "</td>" +
          "<td><ul>" +
          (story.acceptanceCriteria || []).map(function (c) { return "<li>" + escapeHtml(c) + "</li>"; }).join("") +
          "</ul></td>" +
          "<td>" + escapeHtml(story.moscowPriority) + "</td>" +
          "<td>" + escapeHtml(story.estimate) + "<br><small>" + escapeHtml(story.estimateJustification || "") + "</small></td>" +
          "<td>" + escapeHtml(story.initialStatus) + "</td>" +
          "<td>" + escapeHtml((story.dependencies || []).join(", ") || "Sin dependencia") + "</td>" +
          "<td>" + escapeHtml(story.observations || "") + "</td>" +
          "</tr>"
        );
      })
      .join("");
  }

  function normalizeBoardItems(userStories) {
    var storyCards = (userStories.stories || []).map(function (story) {
      return {
        id: story.id,
        title: story.title,
        priority: story.moscowPriority,
        estimate: story.estimate,
        status: story.initialStatus || "Backlog",
        type: "HU"
      };
    });

    var extras = (userStories.boardExtras || []).map(function (item) {
      return {
        id: item.id,
        title: item.title,
        priority: item.moscowPriority || "Should Have",
        estimate: item.estimate || "-",
        status: item.initialStatus || "Backlog",
        type: item.type || "Tarea"
      };
    });

    return storyCards.concat(extras);
  }

  function getFilters() {
    return {
      priority: document.getElementById("priorityFilter").value,
      status: document.getElementById("statusFilter").value,
      type: document.getElementById("typeFilter").value
    };
  }

  function passFilters(item, filters) {
    var passPriority = filters.priority === "all" || item.priority === filters.priority;
    var passStatus = filters.status === "all" || item.status === filters.status;
    var passType = filters.type === "all" || item.type === filters.type;
    return passPriority && passStatus && passType;
  }

  function renderStatusOptions() {
    var select = document.getElementById("statusFilter");
    var options = ["<option value=\"all\">Todos</option>"];

    COLUMN_ORDER.forEach(function (status) {
      options.push("<option value=\"" + escapeHtml(status) + "\">" + escapeHtml(status) + "</option>");
    });

    select.innerHTML = options.join("");
  }

  function saveBoard() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state.boardItems));
  }

  function loadBoardFromStorage() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) {
        return null;
      }
      var parsed = JSON.parse(raw);
      if (!Array.isArray(parsed)) {
        return null;
      }
      return parsed;
    } catch (error) {
      return null;
    }
  }

  function syncTimelineWithBoard() {
    var mapById = {};
    state.boardItems.forEach(function (item) {
      mapById[item.id] = item.status;
    });

    (state.timeline.rows || []).forEach(function (row) {
      if (mapById[row.id]) {
        row.status = mapById[row.id];
      }
    });

    renderTimelineTable();
  }

  function renderBoard() {
    var board = document.getElementById("board");
    var filters = getFilters();

    board.innerHTML = COLUMN_ORDER
      .map(function (status) {
        var items = state.boardItems.filter(function (item) {
          return item.status === status && passFilters(item, filters);
        });

        var cards = items
          .map(function (item) {
            return (
              "<article class=\"board-card\" draggable=\"true\" data-id=\"" + escapeHtml(item.id) + "\" data-priority=\"" + escapeHtml(item.priority) + "\">" +
              "<h4 class=\"board-card__title\">" + escapeHtml(item.title) + "</h4>" +
              "<p class=\"board-card__meta\"><strong>ID:</strong> " + escapeHtml(item.id) + "</p>" +
              "<p class=\"board-card__meta\"><strong>Prioridad:</strong> " + escapeHtml(item.priority) + "</p>" +
              "<p class=\"board-card__meta\"><strong>Fib:</strong> " + escapeHtml(item.estimate) + "</p>" +
              "<p class=\"board-card__meta\"><strong>Estado:</strong> " + escapeHtml(item.status) + "</p>" +
              "<p class=\"board-card__meta\"><strong>Tipo:</strong> " + escapeHtml(item.type) + "</p>" +
              "</article>"
            );
          })
          .join("");

        return (
          "<section class=\"column\" data-status=\"" + escapeHtml(status) + "\">" +
          "<header class=\"column__head\"><span>" + escapeHtml(status) + "</span><strong>" + items.length + "</strong></header>" +
          "<div class=\"column__cards\">" + cards + "</div>" +
          "</section>"
        );
      })
      .join("");

    bindDragAndDrop();
  }

  function bindDragAndDrop() {
    var draggedId = null;
    var cards = document.querySelectorAll(".board-card");
    var columns = document.querySelectorAll(".column");

    cards.forEach(function (card) {
      card.addEventListener("dragstart", function (event) {
        draggedId = event.currentTarget.getAttribute("data-id");
      });
    });

    columns.forEach(function (column) {
      column.addEventListener("dragover", function (event) {
        event.preventDefault();
      });

      column.addEventListener("dragenter", function (event) {
        event.preventDefault();
        column.classList.add("drop-over");
      });

      column.addEventListener("dragleave", function () {
        column.classList.remove("drop-over");
      });

      column.addEventListener("drop", function (event) {
        event.preventDefault();
        column.classList.remove("drop-over");

        var newStatus = column.getAttribute("data-status");
        var item = state.boardItems.find(function (candidate) {
          return candidate.id === draggedId;
        });

        if (!item || !newStatus) {
          return;
        }

        item.status = newStatus;
        saveBoard();
        renderBoard();
        syncTimelineWithBoard();
      });
    });
  }

  function renderTimelineTable() {
    var body = document.getElementById("timelineTableBody");
    body.innerHTML = (state.timeline.rows || [])
      .map(function (row) {
        return (
          "<tr>" +
          "<td>" + escapeHtml(row.id) + "</td>" +
          "<td>" + escapeHtml(row.activity) + "</td>" +
          "<td>" + escapeHtml(row.priority) + "</td>" +
          "<td>" + escapeHtml(row.estimate) + "</td>" +
          "<td>" + escapeHtml(row.designThinkingPhase) + "</td>" +
          "<td>" + escapeHtml(row.suggestedWeek) + "</td>" +
          "<td>" + escapeHtml(row.dependencies) + "</td>" +
          "<td>" + escapeHtml(row.suggestedOwner) + "</td>" +
          "<td>" + escapeHtml(row.expectedDeliverable) + "</td>" +
          "<td>" + escapeHtml(row.status) + "</td>" +
          "</tr>"
        );
      })
      .join("");
  }

  function bindToolbarEvents() {
    ["priorityFilter", "statusFilter", "typeFilter"].forEach(function (id) {
      var element = document.getElementById(id);
      element.addEventListener("change", renderBoard);
    });

    document.getElementById("resetBoardBtn").addEventListener("click", function () {
      state.boardItems = clone(state.initialBoardItems);
      localStorage.removeItem(STORAGE_KEY);
      renderBoard();
      syncTimelineWithBoard();
    });
  }

  function setLoadMode(text, isFallback) {
    var node = document.getElementById("loadMode");
    node.textContent = "Carga: " + text;
    node.classList.remove("load-ok", "load-fallback");
    node.classList.add(isFallback ? "load-fallback" : "load-ok");
  }

  function initialize(data, modeText, isFallback) {
    state.moscow = data.moscow;
    state.designThinking = data.designThinking;
    state.userStories = data.userStories;
    state.timeline = data.timeline;

    renderMoscow(state.moscow);
    renderDesignThinking(state.designThinking);
    renderStoriesTable(state.userStories.stories || []);

    state.initialBoardItems = normalizeBoardItems(state.userStories);
    state.boardItems = loadBoardFromStorage() || clone(state.initialBoardItems);

    renderStatusOptions();
    bindToolbarEvents();
    renderBoard();
    syncTimelineWithBoard();
    setLoadMode(modeText, isFallback);
  }

  function bootstrap() {
    Promise.all([
      loadJson("data/moscow.json"),
      loadJson("data/design-thinking.json"),
      loadJson("data/user-stories.json"),
      loadJson("data/timeline.json")
    ])
      .then(function (response) {
        initialize(
          {
            moscow: response[0],
            designThinking: response[1],
            userStories: response[2],
            timeline: response[3]
          },
          "JSON cargado correctamente",
          false
        );
      })
      .catch(function () {
        initialize(fallbackData(), "modo local sin servidor (fallback)", true);
      });
  }

  bootstrap();
})();
