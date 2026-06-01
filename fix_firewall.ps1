# PowerShell скрипт для налаштування брандмауера
# Запускайте від імені адміністратора

Write-Host "===================================" -ForegroundColor Green
Write-Host "Налаштування брандмауера для Ruby Blog" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Перевірка прав адміністратора
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Потрібні права адміністратора!" -ForegroundColor Red
    Write-Host "Клікніть правою кнопкою на файлі -> 'Запустити від імені адміністратора'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ Права адміністратора є" -ForegroundColor Green

# Видалення старих правил
Write-Host "Видалення старих правил..." -ForegroundColor Yellow
netsh advfirewall firewall delete rule name="Ruby Blog" 2>$null

# Додавання нового правила для входящих підключень
Write-Host "Додавання правила для порту 4567..." -ForegroundColor Yellow
$result = netsh advfirewall firewall add rule name="Ruby Blog" dir=in action=allow protocol=TCP localport=4567

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Правило успішно додано!" -ForegroundColor Green
} else {
    Write-Host "❌ Помилка додавання правила" -ForegroundColor Red
    pause
    exit 1
}

# Перевірка правила
Write-Host "Перевірка правила..." -ForegroundColor Yellow
$rule = Get-NetFirewallRule -DisplayName "Ruby Blog" -ErrorAction SilentlyContinue

if ($rule) {
    Write-Host "✅ Правило знайдено та активне" -ForegroundColor Green
    Write-Host "   Профілі: $($rule.Enabled)" -ForegroundColor White
    Write-Host "   Дія: $($rule.Action)" -ForegroundColor White
    Write-Host "   Протокол: TCP" -ForegroundColor White
    Write-Host "   Порт: 4567" -ForegroundColor White
} else {
    Write-Host "❌ Правило не знайдено" -ForegroundColor Red
}

Write-Host "===================================" -ForegroundColor Green
Write-Host "Тепер запустіть сервер:" -ForegroundColor Cyan
Write-Host "ruby start_server.rb" -ForegroundColor White
Write-Host "===================================" -ForegroundColor Green

Write-Host "Натисніть будь-яку клавішу для виходу..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
