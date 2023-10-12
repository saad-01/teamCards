importScripts("https://www.gstatic.com/firebasejs/7.15.5/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.15.5/firebase-messaging.js");


//Using singleton breaks instantiating messaging()
// App firebase = FirebaseWeb.instance.app;


firebase.initializeApp({
    apiKey: "AIzaSyCv11SU7-UToLKiNpn59hzk1OVinnRBLko",
    authDomain: "nachhaltiges-fahren.firebaseapp.com",
    projectId: "nachhaltiges-fahren",
    storageBucket: "nachhaltiges-fahren.appspot.com",
    messagingSenderId: "359022274075",
    appId: "1:359022274075:web:d728be324906e65fddfabe",
    measurementId: "G-HM8W1T2RSE",
});

const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("Neue Nachricht");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});