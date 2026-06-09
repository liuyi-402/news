@echo off
echo ========================================
echo HarmonyOS 兼容性问题自动修复
echo ========================================
echo.

echo 步骤1: 清理项目
call hvigorw clean

echo.
echo 步骤2: 尝试 debug 构建
echo 这适用于 Beta 版本设备
call hvigorw assembleHap --mode debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Debug 构建成功！
    echo ========================================
    echo.
    echo 请在 DevEco Studio 中运行应用
    echo 如果仍有问题，请运行 build-release.bat
    pause
    exit /b 0
)

echo.
echo Debug 构建失败，尝试 release 构建...
call hvigorw assembleHap --mode release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Release 构建成功！
    echo ========================================
    echo.
    echo 请在 DevEco Studio 中运行应用
    pause
    exit /b 0
)

echo.
echo ========================================
echo 自动修复失败
echo ========================================
echo.
echo 请提供以下信息：
echo 1. 设备型号和系统版本
echo 2. DevEco Studio 版本
echo 3. 完整错误信息
pause
