const STORAGE_KEY = "tara_profile";
const THEME_KEY = "tara_theme";

let currentProfile = null;

// DOM Elements
const sidebar = document.getElementById("sidebar");
const overlay = document.getElementById("overlay");
const profileForm = document.getElementById("profile-form");
const menuForm = document.getElementById("menu-form");
const profileStats = document.getElementById("profile-stats");
const statsDiv = document.getElementById("stats");
const analyzeBtn = document.getElementById("analyze-btn");
const profileBtn = document.getElementById("profile-btn");
const profileStatus = document.getElementById("profile-status");
const resultsSection = document.getElementById("results-section");
const recommendationDiv = document.getElementById("recommendation");
const loading = document.getElementById("loading");
const themeToggle = document.getElementById("theme-toggle");

// --- Theme Management ---
function setTheme(theme) {
  document.documentElement.setAttribute("data-theme", theme);
  localStorage.setItem(THEME_KEY, theme);
}

function initializeTheme() {
  const savedTheme = localStorage.getItem(THEME_KEY);
  const systemPrefersDark =
    window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: dark)").matches;

  if (savedTheme) {
    setTheme(savedTheme);
  } else {
    setTheme(systemPrefersDark ? "dark" : "light");
  }
}

if (themeToggle) {
  themeToggle.addEventListener("click", () => {
    const currentTheme = document.documentElement.getAttribute("data-theme");
    const newTheme = currentTheme === "dark" ? "light" : "dark";
    setTheme(newTheme);
  });
}
// --- End Theme Management ---

// Initialize
document.addEventListener("DOMContentLoaded", () => {
  initializeTheme();
  loadProfile();
});

function toggleSidebar() {
  sidebar.classList.toggle("open");
  overlay.classList.toggle("visible");
}

function loadProfile() {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (saved) {
    const data = JSON.parse(saved);
    fillProfileForm(data);
    calculateAndDisplayProfile(data);
  }
}

function fillProfileForm(data) {
  document.getElementById("weight").value = data.weight_kg || "";
  document.getElementById("height").value = data.height_cm || "";
  document.getElementById("age").value = data.age || "";
  document.getElementById("sex").value = data.sex || "male";
  document.getElementById("activity").value = data.activity_level || "moderate";
  document.getElementById("deficit").value = data.deficit_percent * 100 || 20;
  document.getElementById("meals-per-day").value = data.meals_per_day || 4;
  document.getElementById("body-fat").value = data.body_fat_percent || "";
  document.getElementById("lean-mass").value = data.lean_mass_kg || "";
}

function getProfileData() {
  const data = {
    weight_kg: parseFloat(document.getElementById("weight").value),
    height_cm: parseFloat(document.getElementById("height").value),
    age: parseInt(document.getElementById("age").value),
    sex: document.getElementById("sex").value,
    activity_level: document.getElementById("activity").value,
    deficit_percent: parseInt(document.getElementById("deficit").value) / 100,
    meals_per_day: parseInt(document.getElementById("meals-per-day").value),
  };

  const bodyFat = document.getElementById("body-fat").value;
  const leanMass = document.getElementById("lean-mass").value;

  if (bodyFat) data.body_fat_percent = parseFloat(bodyFat);
  if (leanMass) data.lean_mass_kg = parseFloat(leanMass);

  return data;
}

async function calculateAndDisplayProfile(data) {
  try {
    const response = await fetch("/api/v1/profile", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    if (!response.ok) throw new Error("Erro ao calcular perfil");

    currentProfile = await response.json();
    currentProfile.request = data;

    displayProfileStats(currentProfile);
    updateProfileButton(true);

    return true;
  } catch (error) {
    console.error(error);
    return false;
  }
}

profileForm.addEventListener("submit", async (e) => {
  e.preventDefault();

  const data = getProfileData();
  const success = await calculateAndDisplayProfile(data);

  if (success) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    toggleSidebar();
  }
});

function displayProfileStats(profile) {
  const macros = profile.macros;

  statsDiv.innerHTML = `
        <div class="stat-item">
            <div class="stat-value">${profile.target_calories}</div>
            <div class="stat-label">Calorias/dia</div>
        </div>
        <div class="stat-item">
            <div class="stat-value">${macros.protein_g}g</div>
            <div class="stat-label">Proteína</div>
        </div>
        <div class="stat-item">
            <div class="stat-value">${macros.carbs_g}g</div>
            <div class="stat-label">Carboidratos</div>
        </div>
        <div class="stat-item">
            <div class="stat-value">${macros.fat_g}g</div>
            <div class="stat-label">Gordura</div>
        </div>
    `;

  profileStats.classList.remove("hidden");
}

function updateProfileButton(configured) {
  if (configured) {
    profileBtn.classList.add("configured");
    profileStatus.textContent = `${currentProfile.target_calories} kcal`;
  } else {
    profileBtn.classList.remove("configured");
    profileStatus.textContent = "Configurar";
  }
}

menuForm.addEventListener("submit", async (e) => {
  e.preventDefault();

  if (!currentProfile) {
    toggleSidebar();
    alert("Configure seu perfil primeiro");
    return;
  }

  const menuText = document.getElementById("menu").value;
  const mealType = document.getElementById("meal-type").value;

  loading.classList.remove("hidden");

  try {
    const response = await fetch("/api/v1/analyze", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        profile: currentProfile.request,
        menu_text: menuText,
        meal_type: mealType,
      }),
    });

    if (!response.ok) throw new Error("Erro ao analisar cardápio");

    const result = await response.json();
    displayRecommendation(result.recommendation);
  } catch (error) {
    alert(error.message);
  } finally {
    loading.classList.add("hidden");
  }
});

function displayRecommendation(rec) {
  let html = "";

  rec.escolhas.forEach((item) => {
    html += `
            <div class="food-item">
                <div class="food-header">
                    <span class="food-name">${item.alimento}</span>
                    <span class="food-grams">${item.gramas}g</span>
                </div>
                <div class="food-macros">
                    <span>${item.calorias_estimadas} kcal</span>
                    <span>P: ${item.proteina_g}g</span>
                    <span>C: ${item.carboidrato_g}g</span>
                    <span>G: ${item.gordura_g}g</span>
                </div>
                <div class="food-justification">"${item.justificativa}"</div>
            </div>
        `;
  });

  html += `
        <div class="totals">
            <h4>Total da Refeição</h4>
            <div class="totals-grid">
                <div class="total-item">
                    <strong>${rec.total.calorias}</strong>
                    <span>kcal</span>
                </div>
                <div class="total-item">
                    <strong>${rec.total.proteina_g}g</strong>
                    <span>proteína</span>
                </div>
                <div class="total-item">
                    <strong>${rec.total.carboidrato_g}g</strong>
                    <span>carbs</span>
                </div>
                <div class="total-item">
                    <strong>${rec.total.gordura_g}g</strong>
                    <span>gordura</span>
                </div>
            </div>
        </div>
    `;

  if (rec.dica) {
    html += `
            <div class="tip">
                <strong>💡 Dica:</strong> ${rec.dica}
            </div>
        `;
  }

  recommendationDiv.innerHTML = html;
  resultsSection.classList.remove("hidden");
  resultsSection.scrollIntoView({ behavior: "smooth" });
}

