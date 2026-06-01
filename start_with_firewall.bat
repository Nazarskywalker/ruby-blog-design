@echo off
echo ===================================
echo Налаштування брандмауера для Ruby Blog
echo ===================================

echo Додавання правила для порту 4567...
netsh advfirewall firewall delete rule name="Ruby Blog" >nul 2>&1
netsh advfirewall firewall add rule name="Ruby Blog" dir=in action=allow protocol=TCP localport=4567

if %ERRORLEVEL% EQU 0 (
    echo ✅ Правило успішно додано!
) else (
    echo ❌ Помилка додавання правила. Запустіть від імені адміністратора.
    pause
    exit /b 1
)

echo.
echo ===================================
echo Запуск сервера Ruby Blog
echo ===================================

ruby start_server.rb

pause
