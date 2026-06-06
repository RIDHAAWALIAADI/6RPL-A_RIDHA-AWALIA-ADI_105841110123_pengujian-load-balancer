const express = require('express');
const app = express();
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const SERVER_NAME = process.env.SERVER_NAME || "Kasir-Utama";
const ALGORITHM = process.env.LOAD_BALANCER_ALGO || "Round Robin (Bergantian)";
const LAYER = process.env.LOAD_BALANCER_LAYER || "Layer 7 (Application)";

app.get('/api/status', (req, res) => {
    // Log di console container
    console.log(`[🧍 Pelanggan Datang] Dilayani oleh ${SERVER_NAME}`);
    
    res.json({
        algorithm: ALGORITHM,
        layer: LAYER,
        active_backend: SERVER_NAME.toLowerCase(),
        server_name: SERVER_NAME,
        status: "SIAP MELAYANI TRANSAKSI"
    });
});

app.listen(PORT, () => {
    console.log(`${SERVER_NAME} berjalan pada port ${PORT}, siap melayani antrean.`);
});
