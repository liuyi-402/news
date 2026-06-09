# HarmonyOS 设备兼容性自动修复脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HarmonyOS 设备兼容性自动修复工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 hdc 是否可用
$ hdcAvailable = $false
try {
    $hdcCheck = Get-Command hdc -ErrorAction SilentlyContinue
    if ($hdcCheck) {
        $hdcAvailable = $true
    }
} catch {}

if ($hdcAvailable) {
    Write-Host "✅ 检测到 hdc 工具" -ForegroundColor Green
    
    # 尝试获取设备列表
    Write-Host "📱 正在检测设备..." -ForegroundColor Yellow
    $devices = hdc list targets 2>&1
    
    if ($devices -and $devices.Count -gt 0) {
        Write-Host "✅ 找到设备：" -ForegroundColor Green
        $devices | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
        
        # 尝试获取设备API版本
        Write-Host ""
        Write-Host "🔍 正在获取设备API版本..." -ForegroundColor Yellow
        $apiVersion = hdc shell param get const.ohos.apiversion 2>&1
        
        if ($apiVersion -match "^\d+$") {
            Write-Host "✅ 设备API版本: $apiVersion" -ForegroundColor Green
            
            # 根据API版本自动配置
            $configMap = @{
                "10" = "4.0.0(10)"
                "11" = "4.1.0(11)"
                "12" = "5.0.0(12)"
                "22" = "6.0.2(22)"
            }
            
            if ($configMap.ContainsKey($apiVersion)) {
                $sdkVersion = $configMap[$apiVersion]
                Write-Host "📦 需要配置为: $sdkVersion" -ForegroundColor Yellow
                
                $confirm = Read-Host "是否自动配置？(Y/N)"
                if ($confirm -eq "Y" -or $confirm -eq "y") {
                    # 执行配置
                    & ".\switch-api.ps1" -ApiVersion $apiVersion
                }
            } else {
                Write-Host "⚠️ 未知的API版本: $apiVersion" -ForegroundColor Yellow
                Write-Host "请手动配置 build-profile.json5" -ForegroundColor White
            }
        } else {
            Write-Host "❌ 无法获取设备API版本" -ForegroundColor Red
            Write-Host "请使用方法B手动配置" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ 未找到连接的设备" -ForegroundColor Red
        Write-Host "请确保设备已连接并开启USB调试" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️ 未检测到 hdc 工具" -ForegroundColor Yellow
    Write-Host "请使用方法B手动配置" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "方法B：手动配置指南" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "请在 DevEco Studio 中查看设备信息：" -ForegroundColor Yellow
Write-Host "1. 打开 DevEco Studio" -ForegroundColor White
Write-Host "2. Tools → Device Manager" -ForegroundColor White
Write-Host "3. 选择你的设备" -ForegroundColor White
Write-Host "4. 查看 API Version 和 System Type" -ForegroundColor White
Write-Host ""

Write-Host "然后执行对应的切换命令：" -ForegroundColor Yellow
Write-Host "   .\switch-api.ps1 -ApiVersion 10  # API 10设备" -ForegroundColor White
Write-Host "   .\switch-api.ps1 -ApiVersion 11  # API 11设备" -ForegroundColor White
Write-Host "   .\switch-api.ps1 -ApiVersion 12  # API 12设备" -ForegroundColor White
Write-Host "   .\switch-api.ps1 -ApiVersion 22  # API 22设备" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
