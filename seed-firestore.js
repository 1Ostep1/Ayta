/**
 * Firestore Seed Script — SAN app
 *
 * Seeds all venues and deals from MockData.swift into Firebase Firestore.
 *
 * Setup:
 *   1. npm install firebase-admin
 *   2. Firebase Console → Project Settings → Service accounts → Generate new private key
 *      → save as serviceAccountKey.json next to this file
 *   3. node seed-firestore.js
 */

const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const serviceAccount = require("./serviceAccountKey.json");

initializeApp({ credential: cert(serviceAccount) });

const db = getFirestore();

// ─── Helpers ────────────────────────────────────────────────────────────────

function daysFromNow(n) {
  const d = new Date();
  d.setDate(d.getDate() + n);
  return Timestamp.fromDate(d);
}

// ─── Venues (10 заведений) ───────────────────────────────────────────────────

const venues = [
  {
    id: "navat",
    name: "Navat",
    category: "teahouse",
    district: "Центр",
    address: "пр. Чуй, 125",
    phone: "+996 312 909 000",
    emoji: "🫖",
    gradientFrom: "#E65C00",
    gradientTo: "#F9D423",
    active: true,
  },
  {
    id: "faiza",
    name: "Faiza",
    category: "cafe",
    district: "Восток-5",
    address: "ул. Медерова, 217",
    phone: "+996 555 919 555",
    emoji: "🥟",
    gradientFrom: "#11998E",
    gradientTo: "#38EF7D",
    active: true,
  },
  {
    id: "sierra",
    name: "Sierra Coffee",
    category: "coffee",
    district: "Центр",
    address: "ул. Манаса, 57",
    phone: "+996 312 311 000",
    emoji: "☕️",
    gradientFrom: "#5D4157",
    gradientTo: "#A8CABA",
    active: true,
  },
  {
    id: "bublik",
    name: "Bublik",
    category: "bakery",
    district: "Центр",
    address: "ул. Токтогула, 93",
    phone: "+996 700 905 905",
    emoji: "🥐",
    gradientFrom: "#F7971E",
    gradientTo: "#FFD200",
    active: true,
  },
  {
    id: "furusato",
    name: "Furusato",
    category: "restaurant",
    district: "Центр",
    address: "пр. Эркиндик, 35",
    phone: "+996 555 750 750",
    emoji: "🍣",
    gradientFrom: "#C31432",
    gradientTo: "#240B36",
    active: true,
  },
  {
    id: "chickenstar",
    name: "Chicken Star",
    category: "fastfood",
    district: "Центр",
    address: "пр. Эркиндик, 36",
    phone: "+996 708 700 007",
    emoji: "🍗",
    gradientFrom: "#F12711",
    gradientTo: "#F5AF19",
    active: true,
  },
  {
    id: "cyclone",
    name: "Cyclone",
    category: "restaurant",
    district: "Центр",
    address: "пр. Чуй, 136",
    phone: "+996 312 621 190",
    emoji: "🍝",
    gradientFrom: "#355C7D",
    gradientTo: "#C06C84",
    active: true,
  },
  {
    id: "adriano",
    name: "Adriano Coffee",
    category: "coffee",
    district: "Моссовет",
    address: "ул. Киевская, 77",
    phone: "+996 702 909 290",
    emoji: "🍵",
    gradientFrom: "#3E5151",
    gradientTo: "#DECBA4",
    active: true,
  },
  {
    id: "arzu",
    name: "Арзу",
    category: "cafe",
    district: "Юг-2",
    address: "ул. Горького, 1Б",
    phone: "+996 312 540 540",
    emoji: "🍲",
    gradientFrom: "#870000",
    gradientTo: "#190A05",
    active: true,
  },
  {
    id: "shaurma1",
    name: "Шаурма №1",
    category: "fastfood",
    district: "Аламедин-1",
    address: "ул. Лущихина, 10",
    phone: "+996 550 100 100",
    emoji: "🌯",
    gradientFrom: "#636FA4",
    gradientTo: "#E8CBC0",
    active: true,
  },
];

// ─── Deals (15 предложений) ──────────────────────────────────────────────────

const deals = [
  {
    id: "d1",
    venueID: "navat",
    type: "discount",
    title: "−30% на манты по будням",
    details: "С 11:00 до 15:00 на все виды мантов. Идеально на обед.",
    emoji: "🥟",
    oldPrice: 280,
    newPrice: 195,
    discountPercent: 30,
    validUntil: daysFromNow(12),
  },
  {
    id: "d2",
    venueID: "navat",
    type: "promo",
    title: "Чайник чая в подарок",
    details: "При заказе от 1500 сом — чайник ташкентского чая бесплатно.",
    emoji: "🫖",
    oldPrice: null,
    newPrice: null,
    discountPercent: null,
    validUntil: daysFromNow(6),
  },
  {
    id: "d3",
    venueID: "faiza",
    type: "discount",
    title: "−20% на лагман",
    details: "Фирменный лагман по будням после 16:00.",
    emoji: "🍜",
    oldPrice: 320,
    newPrice: 255,
    discountPercent: 20,
    validUntil: daysFromNow(9),
  },
  {
    id: "d4",
    venueID: "sierra",
    type: "promo",
    title: "1+1 на капучино",
    details: "Каждое утро до 10:00 — второй капучино бесплатно.",
    emoji: "☕️",
    oldPrice: null,
    newPrice: null,
    discountPercent: null,
    validUntil: daysFromNow(20),
  },
  {
    id: "d5",
    venueID: "sierra",
    type: "novelty",
    title: "Bumble с апельсином",
    details: "Новый летний кофе: эспрессо + свежевыжатый апельсин.",
    emoji: "🍊",
    oldPrice: null,
    newPrice: 290,
    discountPercent: null,
    validUntil: daysFromNow(25),
  },
  {
    id: "d6",
    venueID: "bublik",
    type: "discount",
    title: "−50% на выпечку вечером",
    details: "Ежедневно после 20:00 — вся витрина за полцены.",
    emoji: "🥐",
    oldPrice: null,
    newPrice: null,
    discountPercent: 50,
    validUntil: daysFromNow(30),
  },
  {
    id: "d7",
    venueID: "furusato",
    type: "novelty",
    title: "Сет «Бишкек» — 24 ролла",
    details: "Новый большой сет: филадельфия, калифорния, запечённые.",
    emoji: "🍣",
    oldPrice: null,
    newPrice: 1890,
    discountPercent: null,
    validUntil: daysFromNow(18),
  },
  {
    id: "d8",
    venueID: "furusato",
    type: "discount",
    title: "−15% на всё меню по вторникам",
    details: "Весь день, на зал и самовывоз.",
    emoji: "🍱",
    oldPrice: null,
    newPrice: null,
    discountPercent: 15,
    validUntil: daysFromNow(14),
  },
  {
    id: "d9",
    venueID: "chickenstar",
    type: "promo",
    title: "Комбо «Стар» за 390 сом",
    details: "Крылышки + картофель + напиток. Обычная цена 520 сом.",
    emoji: "🍗",
    oldPrice: 520,
    newPrice: 390,
    discountPercent: null,
    validUntil: daysFromNow(8),
  },
  {
    id: "d10",
    venueID: "cyclone",
    type: "discount",
    title: "−25% на пасту в обед",
    details: "Будни с 12:00 до 15:00, вся паста ручной работы.",
    emoji: "🍝",
    oldPrice: 480,
    newPrice: 360,
    discountPercent: 25,
    validUntil: daysFromNow(10),
  },
  {
    id: "d11",
    venueID: "adriano",
    type: "novelty",
    title: "Матча-латте",
    details: "Японская матча церемониального сорта, на любом молоке.",
    emoji: "🍵",
    oldPrice: null,
    newPrice: 270,
    discountPercent: null,
    validUntil: daysFromNow(22),
  },
  {
    id: "d12",
    venueID: "adriano",
    type: "promo",
    title: "Десерт в подарок к кофе",
    details: "С 14:00 до 16:00 — чизкейк или брауни к любому кофе.",
    emoji: "🍰",
    oldPrice: null,
    newPrice: null,
    discountPercent: null,
    validUntil: daysFromNow(5),
  },
  {
    id: "d13",
    venueID: "arzu",
    type: "discount",
    title: "−20% на бешбармак",
    details: "Для компаний от 4 человек, по предзаказу.",
    emoji: "🍲",
    oldPrice: null,
    newPrice: null,
    discountPercent: 20,
    validUntil: daysFromNow(11),
  },
  {
    id: "d14",
    venueID: "shaurma1",
    type: "promo",
    title: "Вторая шаурма −50%",
    details: "На классическую и сырную, ежедневно.",
    emoji: "🌯",
    oldPrice: null,
    newPrice: null,
    discountPercent: null,
    validUntil: daysFromNow(7),
  },
  {
    id: "d15",
    venueID: "shaurma1",
    type: "novelty",
    title: "Шаурма с сыром",
    details: "Двойной сыр, фирменный соус. Уже в меню.",
    emoji: "🧀",
    oldPrice: null,
    newPrice: 250,
    discountPercent: null,
    validUntil: daysFromNow(16),
  },
];

// ─── Seed ────────────────────────────────────────────────────────────────────

async function seed() {
  console.log("🔥 Seeding Firestore...\n");

  // Venues
  const venuesBatch = db.batch();
  for (const { id, ...data } of venues) {
    // Remove null fields to keep Firestore docs clean
    const clean = Object.fromEntries(
      Object.entries(data).filter(([, v]) => v !== null)
    );
    venuesBatch.set(db.collection("venues").doc(id), clean);
  }
  await venuesBatch.commit();
  console.log(`✅ venues: ${venues.length} documents written`);

  // Deals
  const dealsBatch = db.batch();
  for (const { id, ...data } of deals) {
    const clean = Object.fromEntries(
      Object.entries(data).filter(([, v]) => v !== null)
    );
    dealsBatch.set(db.collection("deals").doc(id), clean);
  }
  await dealsBatch.commit();
  console.log(`✅ deals:  ${deals.length} documents written`);

  console.log("\n🎉 Done! Open Firebase Console to verify.");
  process.exit(0);
}

seed().catch((err) => {
  console.error("❌ Seed failed:", err);
  process.exit(1);
});
