importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
apiKey: 'AIzaSyCohmmMIBzCjuVAoteWmLYmh77ZVpqYIxk',
    appId: '1:1037784419913:web:6a18c3db7387c8e206f998',
    messagingSenderId: '1037784419913',
    projectId: 'careai-c7ce0',
    authDomain: 'careai-c7ce0.firebaseapp.com',
    storageBucket: 'careai-c7ce0.firebasestorage.app',
    measurementId: 'G-FCT4KS35M5',
});

const messaging = firebase.messaging();