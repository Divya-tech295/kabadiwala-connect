const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();

setGlobalOptions({maxInstances: 10});

const db = getFirestore();

/*
 * ============================================================
 * 1. GET LATEST MARKET RATE
 * ============================================================
 */

exports.getMarketRate = onRequest(async (req, res) => {
  try {
    const city = String(req.query.city || "").trim();
    const material = String(req.query.material || "").trim();

    if (!city || !material) {
      return res.status(400).json({
        success: false,
        error: "city and material are required",
      });
    }

    const snapshot = await db
        .collection("market_rates")
        .where("city", "==", city)
        .where("material", "==", material)
        .orderBy("date", "desc")
        .limit(1)
        .get();

    if (snapshot.empty) {
      return res.status(404).json({
        success: false,
        error: "No market rate available for this city and material",
        city: city,
        material: material,
      });
    }

    return res.status(200).json({
      success: true,
      data: snapshot.docs[0].data(),
    });
  } catch (error) {
    logger.error("Market rate lookup error", error);

    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});
/*
 * ============================================================
 * 1B. GET 7-DAY MARKET RATE HISTORY
 * ============================================================
 */

exports.getMarketRateHistory = onRequest(
    async (req, res) => {
      try {
        const city = String(
            req.query.city || "",
        ).trim();

        const material = String(
            req.query.material || "",
        ).trim();

        if (!city || !material) {
          return res.status(400).json({
            success: false,
            error: "city and material are required",
          });
        }

        const snapshot = await db
            .collection("market_rates")
            .where("city", "==", city)
            .where("material", "==", material)
            .orderBy("date", "desc")
            .limit(7)
            .get();

        const data = snapshot.docs.map(
            (doc) => doc.data(),
        );

        return res.status(200).json({
          success: true,
          city: city,
          material: material,
          days: data.length,
          data: data,
        });
      } catch (error) {
        logger.error(
            "Market rate history error",
            error,
        );

        return res.status(500).json({
          success: false,
          error: error.message,
        });
      }
    },
);

/*
 * ============================================================
 * 2. ALL SCRAPPRICE CITY PAGES
 * ============================================================
 */

const cities = [
  {
    name: "Ahmedabad",
    slug: "ahmedabad",
  },
  {
    name: "Bengaluru Urban",
    slug: "bengaluru-urban",
  },
  {
    name: "Bhopal",
    slug: "bhopal",
  },
  {
    name: "Chandigarh",
    slug: "chandigarh",
  },
  {
    name: "Chennai",
    slug: "chennai",
  },
  {
    name: "Cochin",
    slug: "cochin",
  },
  {
    name: "Coimbatore",
    slug: "coimbatore",
  },
  {
    name: "Gurugram",
    slug: "gurugram",
  },
  {
    name: "Hyderabad",
    slug: "hyderabad",
  },
  {
    name: "Indore",
    slug: "indore",
  },
  {
    name: "Jaipur",
    slug: "jaipur",
  },
  {
    name: "Jammu",
    slug: "jammu",
  },
  {
    name: "Jamnagar",
    slug: "jamnagar",
  },
  {
    name: "Kanpur",
    slug: "kanpur",
  },
  {
    name: "Kolkata",
    slug: "kolkata",
  },
  {
    name: "Lucknow",
    slug: "lucknow",
  },
  {
    name: "Ludhiana",
    slug: "ludhiana",
  },
  {
    name: "Mandi Gobindgarh",
    slug: "mandi-gobindgarh",
  },
  {
    name: "Mumbai",
    slug: "mumbai",
  },
  {
    name: "Nagpur",
    slug: "nagpur",
  },
  {
    name: "New Delhi",
    slug: "new-delhi",
  },
  {
    name: "Pune",
    slug: "pune",
  },
  {
    name: "Surat",
    slug: "surat",
  },
  {
    name: "Vadodara",
    slug: "vadodara",
  },
];/*
 * ============================================================
 * 3. PARSE SCRAPPRICE QUICK RATE CARDS
 * ============================================================
 */
/**
 * Parses Scrapprice quick-rate cards for one city.
 */
/**
 * Parses Scrapprice quick-rate cards for one city.
 */
/**
 * Parses Scrapprice price-index table for one city.
 *
 * @param {string} html HTML content of the city page.
 * @param {Object} city City information.
 * @return {Array<Object>} Parsed market-rate records.
 */
function parseCityRates(html, city) {
  const results = [];
  const tablePattern = new RegExp(
      "<tr>\\s*" +
      "<td[^>]*class=[\"']idx-mat[\"'][^>]*>\\s*" +
      "<a[^>]*>([^<]+)<\\/a>\\s*" +
      "<\\/td>\\s*" +
      "<td[^>]*class=[\"']idx-price[\"'][^>]*>\\s*" +
      "₹\\s*([0-9,.]+)\\s*\\/\\s*([^<]+)" +
      "<\\/td>\\s*" +
      "<td[^>]*class=[\"']idx-range[\"'][^>]*>\\s*" +
      "₹\\s*([0-9,.]+)\\s*[–-]\\s*₹\\s*([0-9,.]+)" +
      "<\\/td>[\\s\\S]*?" +
      "<span[^>]*class=[\"']chg\\s+([^\"']+)[\"'][^>]*>\\s*" +
      "([▲▼—])?\\s*([0-9.]+)?%?\\s*" +
      "<\\/span>",
      "gi",
  );

  let match;

  while ((match = tablePattern.exec(html)) !== null) {
    const material = match[1].trim();

    const rate = Number(
        match[2].replace(/,/g, ""),
    );

    const unit = match[3].trim().toLowerCase();

    const lowRate = Number(
        match[4].replace(/,/g, ""),
    );

    const highRate = Number(
        match[5].replace(/,/g, ""),
    );

    const changeClass = match[6] || "";

    const changeDirection = match[7] || (
      changeClass.includes("up") ? "▲" :
      changeClass.includes("down") ? "▼" :
      "—"
    );

    const changePercent = match[8] ?
      Number(match[8]) :
      0;

    if (
      !material ||
      !Number.isFinite(rate)
    ) {
      continue;
    }

    results.push({
      city: city.name,
      material: material,
      rate: rate,
      unit: unit,
      lowRate: Number.isFinite(lowRate) ?
        lowRate :
        null,
      highRate: Number.isFinite(highRate) ?
        highRate :
        null,
      changeDirection: changeDirection,
      changePercent: changePercent,
    });
  }

  const unique = new Map();

  for (const item of results) {
    const key = item.material.toLowerCase();

    if (!unique.has(key)) {
      unique.set(key, item);
    }
  }

  return [...unique.values()];
}
/*
 * ============================================================
 * 4. FETCH ONE CITY
 * ============================================================
 */
/**
 * Fetches Scrapprice rates for one city.
 */
/**
 * Fetches Scrapprice rates for one city.
 *
 * @param {string} city City name.
 * @return {Promise<Array<Object>>} Parsed market-rate records.
 */
async function fetchCityRates(city) {
  const url = `https://www.scrapprice.in/${city.slug}`;

  const response = await fetch(url, {
    headers: {
      "User-Agent":
        "KabadiwalaConnect-MVP/1.0",
    },
  });

  if (!response.ok) {
    throw new Error(
        `${city.name}: HTTP ${response.status}`,
    );
  }

  const html = await response.text();

  const rates = parseCityRates(
      html,
      city,
  );

  return {
    city: city.name,
    url: url,
    rates: rates,
  };
}


/*
 * ============================================================
 * 5. FETCH ALL INDIA CITY RATES + SAVE FIRESTORE
 * ============================================================
 */

exports.updateAllIndiaMarketRates = onRequest(
    async (req, res) => {
      try {
        const today = new Date()
            .toISOString()
            .slice(0, 10);

        const allResults = [];
        const cityResults = [];
        const errors = [];

        /*
         * Fetch every city one by one.
         *
         * This is intentionally sequential so that
         * we do not overload the source website.
         */

        for (const city of cities) {
          try {
            const result = await fetchCityRates(city);

            cityResults.push({
              city: city.name,
              count: result.rates.length,
            });

            for (const rate of result.rates) {
              allResults.push({
                ...rate,
                source: "Scrapprice",
                sourceType:
                  "indicative_market_rate",
                sourceUrl: result.url,
                date: today,
                updatedAt: new Date(),
              });
            }
          } catch (error) {
            logger.error(
                `Failed to fetch ${city.name}`,
                error,
            );

            errors.push({
              city: city.name,
              error: error.message,
            });
          }
        }

        /*
         * Save all fetched rates.
         */

        const batch = db.batch();

        for (const item of allResults) {
          const safeCity = item.city
              .replace(/[^a-zA-Z0-9]+/g, "_");

          const safeMaterial = item.material
              .replace(/[^a-zA-Z0-9]+/g, "_");

          const docId =
            `${safeCity}_${safeMaterial}_${today}`;

          const docRef = db
              .collection("market_rates")
              .doc(docId);

          batch.set(
              docRef,
              {
                city: item.city,
                material: item.material,
                rate: item.rate,
                unit: item.unit,
                changeDirection:
    item.changeDirection,
                changePercent:
    item.changePercent,
                lowRate:
    item.lowRate,
                highRate:
    item.highRate,
                source: item.source,
                sourceType:
                  item.sourceType,
                sourceUrl:
                  item.sourceUrl,
                date: item.date,
                updatedAt: item.updatedAt,
              },
              {
                merge: true,
              },
          );
        }

        await batch.commit();

        return res.status(200).json({
          success: true,
          date: today,
          citiesRequested: cities.length,
          totalRatesSaved: allResults.length,
          cityResults: cityResults,
          errors: errors,
          data: allResults,
          disclaimer:
            "These are indicative benchmark rates. Actual prices may vary by " +
"material grade, quantity and recycler.",
        });
      } catch (error) {
        logger.error(
            "All India market rate update failed",
            error,
        );

        return res.status(500).json({
          success: false,
          error: error.message,
        });
      }
    },
);


/*
 * ============================================================
 * 6. TEST ONE CITY
 * ============================================================
 *
 * Example:
 * /testScrappriceFetch?city=Jaipur
 */

exports.testScrappriceFetch = onRequest(
    async (req, res) => {
      try {
        const requestedCity = String(
            req.query.city || "Jaipur",
        ).trim();

        const city = cities.find(
            (item) =>
              item.name.toLowerCase() ===
              requestedCity.toLowerCase(),
        );

        if (!city) {
          return res.status(404).json({
            success: false,
            error: "City not found in Scrapprice city list",
            availableCities:
              cities.map((item) => item.name),
          });
        }

        const result = await fetchCityRates(city);

        return res.status(200).json({
          success: true,
          city: result.city,
          sourceUrl: result.url,
          count: result.rates.length,
          data: result.rates,
        });
      } catch (error) {
        logger.error(
            "Scrapprice test fetch failed",
            error,
        );

        return res.status(500).json({
          success: false,
          error: error.message,
        });
      }
    },
);
// =====================================================
// RECYCLER DATA UPDATE
// =====================================================

exports.updateRecyclerData = onRequest(async (req, res) => {
  try {
    const recyclers = [
      {
        recyclerId: "RJ-JPR-001",
        name: "M/s ETCO E-Waste Recycler Private Ltd",
        address:
          "SB-23, Shilp Bari, Road No. 14-15, VKI Area, Jaipur",
        city: "Jaipur",
        state: "Rajasthan",
        activity: "Recycling & Refurbishing",
        registrationStatus: "Authorised by RSPCB",
        sourceAuthority:
          "Rajasthan State Pollution Control Board",
        sourceUrl:
          "https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html",
        lastChecked: "2026-09-26",
      },
    ];

    let uploaded = 0;

    for (const recycler of recyclers) {
      await db
          .collection("recyclers")
          .doc(recycler.recyclerId)
          .set(recycler, {merge: true});

      uploaded++;
    }

    return res.status(200).json({
      success: true,
      message: "Recycler data updated successfully",
      uploaded,
    });
  } catch (error) {
    logger.error("Recycler update failed", error);

    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});
