# 自动修复脚本 - 尝试所有可能的配置组合

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "华为Mate 70 兼容性自动修复" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# API版本列表
$apiConfigs = @(
    @{
        Name = "API 12 (HarmonyOS 5.0)"
        Target = "5.0.0(12)"
        Compatible = "5.0.0(12)"
    },
    @{
        Name = "API 11 (HarmonyOS 4.1)"
        Target = "4.1.0(11)"
        Compatible = "4.1.0(11)"
    },
    @{
        Name = "API 10 (HarmonyOS 4.0)"
        Target = "4.0.0(10)"
        Compatible = "4.0.0(10)"
    }
)

# 构建模式列表
$buildModes = @("release", "debug")

$success = $false

foreach ($api in $apiConfigs) {
    if ($success) { break }
    
    Write-Host "尝试配置: $($api.Name)" -ForegroundColor Yellow
    
    # 更新 build-profile.json5
    $config = @{
        app = @{
            signingConfigs = @()
            products = @(
                @{
                    name = "default"
                    signingConfig = "default"
                    targetSdkVersion = $api.Target
                    compatibleSdkVersion = $api.Compatible
                    runtimeOS = "HarmonyOS"
                }
            )
            buildModeSet = @(
                @{ name = "debug" },
                @{ name = "release" }
            )
        }
        modules = @(
            @{
                name = "entry"
                srcPath = "./entry"
                targets = @(
                    @{
                        name = "default"
                        applyToProducts = @("default")
                    }
                )
            }
        )
    }
    
    $config | ConvertTo-Json -Depth 10 | Out-File "build-profile.json5" -Encoding UTF8
    
    foreach ($mode in $buildModes) {
        Write-Host "  构建模式: $mode" -ForegroundColor Gray
        
        # 清理
        hvigorw clean 2>&1 | Out-Null
        
        # 构建
        $result = hvigorw assembleHap --mode $mode 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "✅ 成功！" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "配置: $($api.Name)" -ForegroundColor White
            Write-Host "模式: $mode" -ForegroundColor White
            Write-Host ""
            Write-Host "请在 DevEco Studio 中运行应用" -ForegroundColor Yellow
            $success = $true
            break
        }
    }
}

if (-not $success) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "❌ 所有配置尝试失败" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查：" -ForegroundColor Yellow
    Write-Host "1. 设备是否已连接" -ForegroundColor White
    Write-Host "2. USB调试是否开启" -ForegroundColor White
    Write-Host "3. DevEco Studio版本是否支持" -ForegroundColor White
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
