$url = "http://localhost:8080/api/status"

Clear-Host

Write-Host "=============================================" -ForegroundColor Yellow
Write-Host "  MENGECEK KONDISI KASIR MINIMARKET...       " -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host ""

try {
    $firstRaw = curl.exe -s -H "Connection: close" $url

    if ([string]::IsNullOrWhiteSpace($firstRaw)) {
        Write-Host "[!] Toko Tutup: Tidak ada respon dari kasir." -ForegroundColor Red
        Write-Host "Pastikan Docker dan NGINX sudah berjalan." -ForegroundColor Red
        Write-Host ""
        Write-Host "Coba buka toko dulu dengan perintah:" -ForegroundColor Cyan
        Write-Host "docker compose down --remove-orphans"
        Write-Host "docker compose up --build --force-recreate"
        exit
    }

    $firstResponse = $firstRaw | ConvertFrom-Json
    $algorithm = $firstResponse.algorithm

    if ([string]::IsNullOrWhiteSpace($algorithm)) {
        $algorithm = "Antrean Acak"
    }

    Clear-Host

    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "  SIMULASI ANTREAN KASIR: $($algorithm.ToUpper())" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""

    $kasir = $firstResponse.active_backend
    if ([string]::IsNullOrWhiteSpace($kasir)) { $kasir = $firstResponse.server_name }

    Write-Host "[🧍 Pelanggan 1] Masuk ke antrean..." -ForegroundColor Cyan
    Write-Host "Sistem Antrean : $($firstResponse.algorithm)"
    Write-Host "Lantai / Area  : $($firstResponse.layer)"
    Write-Host "Kasir Melayani : $($kasir.ToUpper())" -ForegroundColor Magenta
    Write-Host "Status Kasir   : $($firstResponse.status)"
    Write-Host "---------------------------------------------"

    for ($i = 2; $i -le 10; $i++) {
        Start-Sleep -Milliseconds 600

        $raw = curl.exe -s -H "Connection: close" $url

        if ([string]::IsNullOrWhiteSpace($raw)) {
            Write-Host "[❌ Pelanggan $i] Gagal dilayani: Kasir mendadak sibuk/error." -ForegroundColor Red
            Write-Host "---------------------------------------------"
            continue
        }

        $response = $raw | ConvertFrom-Json
        
        $kasirMaju = $response.active_backend
        if ([string]::IsNullOrWhiteSpace($kasirMaju)) { $kasirMaju = $response.server_name }

        Write-Host "[🧍 Pelanggan $i] Masuk ke antrean..." -ForegroundColor Cyan
        Write-Host "Sistem Antrean : $($response.algorithm)"
        Write-Host "Lantai / Area  : $($response.layer)"
        Write-Host "Kasir Melayani : $($kasirMaju.ToUpper())" -ForegroundColor Magenta
        Write-Host "Status Kasir   : $($response.status)"
        Write-Host "---------------------------------------------"
    }

    Write-Host ""
    Write-Host "Simulasi antrean selesai!" -ForegroundColor Green
    Write-Host "Analisis: Jika Kasir bergantian melayani pelanggan (misal: app1, app2, app3)," -ForegroundColor Yellow
    Write-Host "artinya pembagian antrean (Load Balancer) di minimarket Anda bekerja dengan adil!" -ForegroundColor Yellow
}
catch {
    Write-Host "[🚨] Terjadi kekacauan di antrean minimarket!" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
