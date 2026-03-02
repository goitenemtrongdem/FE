importScripts("https://www.gstatic.com/firebasejs/9.22.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.2/firebase-messaging-compat.js");

console.log("✅ firebase-messaging-sw.js loaded");

firebase.initializeApp({
  apiKey: "AIzaSyAp8_ww4_nez_MClt-NOrxOk82Hf7TMG6A",
  authDomain: "iot-chong-trom-xe-may.firebaseapp.com",
  projectId: "iot-chong-trom-xe-may",
  storageBucket: "iot-chong-trom-xe-may.appspot.com",
  messagingSenderId: "644959023893",
  appId: "1:644959023893:web:28ab731861add98e73ef1c",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log("📩 Background message received:", payload);

  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  });
});