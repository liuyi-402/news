# 一键修复脚本 - 尝试所有可能的API版本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HarmonyOS 兼容性问题一键修复" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = $PSScriptRoot
$buildProfile = Join-Path $projectRoot "build-profile.json5"

# API版本列表（从最常见到最少见）
$apiVersions = @("12", "11", "10", "22")

Write-Host "🔄 将尝试以下API版本配置：" -ForegroundColor Yellow
Write-Host "   1. API 12 (HarmonyOS 5.0) - 最新设备" -ForegroundColor White
Write-Host "   2. API 11 (HarmonyOS 4.1) - Mate 60系列" -ForegroundColor White
Write-Host "   3. API 10 (HarmonyOS 4.0) - 旧版设备" -ForegroundColor White
Write-Host "   4. API 22 (HarmonyOS Next) - 开发者预览" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "是否开始自动尝试？(Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "已取消" -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

foreach ($api in $apiVersions) {
    Write-Host ""
    Write-Host "🔍 尝试 API $api 配置..." -ForegroundColor Yellow
    
    # 切换配置
    $sourceFile = Join-Path $projectRoot "build-profile-API$api.json5"
    if (Test-Path $sourceFile) {
        Copy-Item $sourceFile $buildProfile -Force
        Write-Host "   ✅ 已切换到 API $api" -ForegroundColor Green
        
        # 清理并构建
        Write-Host "   🔨 构建项目..." -ForegroundColor Gray
        hvigorw clean 2>&1 | Out-Null
        $buildResult = hvigorw assembleHap 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ 构建成功！" -ForegroundColor Green
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "🎉 修复成功！" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "当前配置：API $api" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "🚀 请在DevEco Studio中运行应用" -ForegroundColor Cyan
            Write-Host "   如果仍有问题，请尝试下一个API版本" -ForegroundColor Gray
            Write-Host ""
            
            $continue = Read-Host "是否继续尝试下一个API版本？(Y/N)"
            if ($continue -ne "Y" -and $continue -ne "y") {
                exit
            }
        } else {
            Write-Host "   ❌ 构建失败" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️ 配置文件不存在" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "⚠️ 所有API版本都已尝试" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "如果问题仍然存在，请检查：" -ForegroundColor Yellow
Write-Host "1. 设备是否为Beta版本（需要debug构建）" -ForegroundColor White
Write-Host "2. DevEco Studio版本是否最新" -ForegroundColor White
Write-Host "3. SDK是否正确安装" -ForegroundColor White
Write-Host ""
Write-Host "或提供以下信息以获取定制化解决方案：" -ForegroundColor Yellow
Write-Host "- 设备型号和系统版本" -ForegroundColor White
Write-Host "- DevEco Studio版本" -ForegroundColor White
Write-Host "- 完整错误信息" -ForegroundColor White
