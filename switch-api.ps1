# HarmonyOS API版本快速切换脚本

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("10", "11", "12", "22")]
    [string]$ApiVersion
)

$projectRoot = $PSScriptRoot
$targetFile = Join-Path $projectRoot "build-profile.json5"
$sourceFile = Join-Path $projectRoot "build-profile-API$ApiVersion.json5"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HarmonyOS API版本切换工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查源文件是否存在
if (-not (Test-Path $sourceFile)) {
    Write-Host "❌ 错误：找不到配置文件 build-profile-API$ApiVersion.json5" -ForegroundColor Red
    exit 1
}

# 备份当前配置
$backupFile = Join-Path $projectRoot "build-profile-backup.json5"
if (Test-Path $targetFile) {
    Copy-Item $targetFile $backupFile -Force
    Write-Host "✅ 已备份当前配置到 build-profile-backup.json5" -ForegroundColor Green
}

# 复制新配置
Copy-Item $sourceFile $targetFile -Force
Write-Host "✅ 已切换到 API $ApiVersion 配置" -ForegroundColor Green

# 显示版本信息
$versionMap = @{
    "10" = "HarmonyOS 4.0"
    "11" = "HarmonyOS 4.1"
    "12" = "HarmonyOS 5.0"
    "22" = "HarmonyOS Next"
}

Write-Host ""
Write-Host "📋 配置信息：" -ForegroundColor Yellow
Write-Host "   API版本: $ApiVersion" -ForegroundColor White
Write-Host "   系统版本: $($versionMap[$ApiVersion])" -ForegroundColor White
Write-Host ""

# 询问是否重新构建
$build = Read-Host "是否立即重新构建项目？(Y/N)"
if ($build -eq "Y" -or $build -eq "y") {
    Write-Host ""
    Write-Host "🔨 开始构建项目..." -ForegroundColor Yellow
    
    # 清理项目
    Write-Host "   清理旧构建..." -ForegroundColor Gray
    hvigorw clean 2>&1 | Out-Null
    
    # 构建项目
    Write-Host "   构建HAP..." -ForegroundColor Gray
    $buildResult = hvigorw assembleHap 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 构建成功！" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 现在可以运行应用了" -ForegroundColor Cyan
    } else {
        Write-Host "❌ 构建失败" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "💡 提示：请手动执行以下命令重新构建：" -ForegroundColor Yellow
    Write-Host "   hvigorw clean" -ForegroundColor White
    Write-Host "   hvigorw assembleHap" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
