require("dotenv").config();

const express = require("express");
const cors = require("cors");
const axios = require("axios");
const jwt = require("jsonwebtoken");
const { v4: uuidv4 } = require("uuid");
const admin = require("firebase-admin");

// ---------------------------------------------------------------------------
// Firebase Admin Initialization
// ---------------------------------------------------------------------------
// Option 1: Use GOOGLE_APPLICATION_CREDENTIALS env var (points to JSON file)
// Option 2: Directly pass a service account object
const serviceAccount = process.env.GOOGLE_APPLICATION_CREDENTIALS
  ? require(process.env.GOOGLE_APPLICATION_CREDENTIALS.startsWith(".")
      ? require("path").resolve(__dirname, process.env.GOOGLE_APPLICATION_CREDENTIALS)
      : process.env.GOOGLE_APPLICATION_CREDENTIALS)
  : undefined;

admin.initializeApp({
  credential: serviceAccount
    ? admin.credential.cert(serviceAccount)
    : admin.credential.applicationDefault(),
});

const db = admin.firestore();

// ---------------------------------------------------------------------------
// Express App Setup
// ---------------------------------------------------------------------------
const app = express();
app.use(cors());
app.use(express.json());

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const MSG91_BASE_URL = "https://control.msg91.com/api/v5";
const MSG91_AUTH_KEY = process.env.MSG91_AUTH_KEY;
const MSG91_TEMPLATE_ID = process.env.MSG91_TEMPLATE_ID;
const JWT_SECRET = process.env.JWT_SECRET;
const PORT = process.env.PORT || 3001;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Formats a 10-digit Indian mobile number to include the country code.
 * Accepts "9876543210" or "919876543210" and always returns "919876543210".
 */
function formatMobile(phone) {
  const digits = phone.replace(/\D/g, "");
  if (digits.startsWith("91") && digits.length === 12) return digits;
  if (digits.length === 10) return `91${digits}`;
  return digits; // pass-through for other formats
}

/**
 * Basic phone validation – expects a 10-digit Indian mobile number.
 */
function isValidPhone(phone) {
  return /^\d{10}$/.test(phone);
}

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------

// Health check
app.get("/", (_req, res) => {
  res.json({ status: "ok", service: "vexo-auth" });
});

// ---- 1. SEND OTP --------------------------------------------------------
app.post("/api/auth/send-otp", async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ success: false, message: "Phone number is required." });
    }
    if (!isValidPhone(phone)) {
      return res.status(400).json({ success: false, message: "Invalid phone number. Provide a 10-digit mobile number." });
    }

    const mobile = formatMobile(phone);

    const response = await axios.post(
      `${MSG91_BASE_URL}/otp`,
      {
        template_id: MSG91_TEMPLATE_ID,
        mobile,
      },
      {
        headers: {
          authkey: MSG91_AUTH_KEY,
          "Content-Type": "application/json",
        },
      }
    );

    return res.status(200).json({
      success: true,
      message: "OTP sent successfully.",
      data: response.data,
    });
  } catch (error) {
    console.error("Send OTP Error:", error?.response?.data || error.message);
    const status = error?.response?.status || 500;
    return res.status(status).json({
      success: false,
      message: "Failed to send OTP.",
      error: error?.response?.data || error.message,
    });
  }
});

// ---- 2. VERIFY OTP -------------------------------------------------------
app.post("/api/auth/verify-otp", async (req, res) => {
  try {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({ success: false, message: "Phone number and OTP are required." });
    }
    if (!isValidPhone(phone)) {
      return res.status(400).json({ success: false, message: "Invalid phone number. Provide a 10-digit mobile number." });
    }

    const mobile = formatMobile(phone);

    // Step 1: Verify OTP with MSG91
    const verifyResponse = await axios.post(
      `${MSG91_BASE_URL}/otp/verify`,
      {
        otp,
        mobile,
      },
      {
        headers: {
          authkey: MSG91_AUTH_KEY,
          "Content-Type": "application/json",
        },
      }
    );

    // MSG91 returns { type: "success", message: "..." } on valid OTP
    if (verifyResponse.data?.type !== "success") {
      return res.status(401).json({
        success: false,
        message: "OTP verification failed.",
        data: verifyResponse.data,
      });
    }

    // Step 2: Check if user exists in Firestore
    const usersRef = db.collection("users");
    const snapshot = await usersRef.where("phone", "==", phone).limit(1).get();

    let userData;
    let docId;

    if (snapshot.empty) {
      // Step 3: Create new user
      const uid = uuidv4();
      userData = {
        uid,
        phone,
        name: "",
        role: "customer",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      const newDocRef = await usersRef.add(userData);
      docId = newDocRef.id;
      userData.isNewUser = true;
    } else {
      // Existing user
      const userDoc = snapshot.docs[0];
      docId = userDoc.id;
      userData = userDoc.data();
      userData.isNewUser = false;
    }

    // Step 4: Generate JWT
    const token = jwt.sign(
      {
        userId: docId,
        phone: userData.phone,
        role: userData.role,
      },
      JWT_SECRET,
      { expiresIn: "30d" }
    );

    return res.status(200).json({
      success: true,
      message: "OTP verified successfully.",
      token,
      user: {
        id: docId,
        uid: userData.uid,
        phone: userData.phone,
        name: userData.name,
        role: userData.role,
        isNewUser: userData.isNewUser,
      },
    });
  } catch (error) {
    console.error("Verify OTP Error:", error?.response?.data || error.message);
    const status = error?.response?.status || 500;
    return res.status(status).json({
      success: false,
      message: "OTP verification failed.",
      error: error?.response?.data || error.message,
    });
  }
});

// ---- 3. RESEND OTP -------------------------------------------------------
app.post("/api/auth/resend-otp", async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ success: false, message: "Phone number is required." });
    }
    if (!isValidPhone(phone)) {
      return res.status(400).json({ success: false, message: "Invalid phone number. Provide a 10-digit mobile number." });
    }

    const mobile = formatMobile(phone);

    const response = await axios.post(
      `${MSG91_BASE_URL}/otp/retry`,
      {
        mobile,
        retrytype: "text",
      },
      {
        headers: {
          authkey: MSG91_AUTH_KEY,
          "Content-Type": "application/json",
        },
      }
    );

    return res.status(200).json({
      success: true,
      message: "OTP resent successfully.",
      data: response.data,
    });
  } catch (error) {
    console.error("Resend OTP Error:", error?.response?.data || error.message);
    const status = error?.response?.status || 500;
    return res.status(status).json({
      success: false,
      message: "Failed to resend OTP.",
      error: error?.response?.data || error.message,
    });
  }
});

// ---------------------------------------------------------------------------
// Start Server
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
  console.log(`🚀 Vexo Auth Server running on http://localhost:${PORT}`);
});
