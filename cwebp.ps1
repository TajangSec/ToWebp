# 指定 cwebp.exe 路径
$CWebpPath = "绝对路径！Absolute path！"

# 指定输入目录（包含 JPG 和 PNG 图片）
$InputDir = "绝对路径！Absolute path！"

# 指定输出目录
$OutputDir = "绝对路径！Absolute path！"

# 线程数限制
$MaxThreads = 8

# 确保输出目录存在
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# 获取所有文件
$Files = Get-ChildItem -Path $InputDir -File -Recurse

# 线程管理
$Jobs = New-Object System.Collections.ArrayList
foreach ($File in $Files) {
    # 计算相对路径并创建相应的子目录
    $RelativePath = $File.FullName.Substring($InputDir.Length).TrimStart('\')
    $OutputSubDir = Split-Path (Join-Path $OutputDir $RelativePath) -Parent
    if (!(Test-Path $OutputSubDir)) {
        New-Item -ItemType Directory -Path $OutputSubDir | Out-Null
    }

    # 检查是否为 JPG/PNG 文件
    if ($File.Extension -match "\.jpg|\.png") {
        # 启动新任务
        $Job = Start-Job -ScriptBlock {
            param ($CWebpPath, $InputFile, $OutputSubDir, $BaseName, $RelativePath)

            # 生成 WebP 输出文件路径
            $BaseOutputFile = Join-Path $OutputSubDir ("$BaseName.webp")
            $OutputFile = $BaseOutputFile

            # 处理重名文件
            $Counter = 1
            while (Test-Path $OutputFile) {
                $OutputFile = Join-Path $OutputSubDir ("$BaseName ($Counter).webp")
                $Counter++
            }

            # 记录重命名日志
            if ($OutputFile -ne $BaseOutputFile) {
                Write-Output "$RelativePath ===>转换时遇到同名文件，已重命名为 $(Split-Path -Leaf $OutputFile)"
            }

            # 调用 cwebp 转换，并忽略标准输出
            & $CWebpPath $InputFile -o $OutputFile 2>&1 | Out-Null

        } -ArgumentList $CWebpPath, $File.FullName, $OutputSubDir, $File.BaseName, $RelativePath

        # 添加作业到列表
        [void]$Jobs.Add($Job)

        # 控制线程数
        while ($Jobs.Count -ge $MaxThreads) {
            $CompletedJobs = $Jobs | Where-Object { $_.State -ne 'Running' }
            foreach ($j in $CompletedJobs) {
                Receive-Job $j
                Remove-Job $j
                [void]$Jobs.Remove($j)
            }
            if ($Jobs.Count -ge $MaxThreads) {
                Start-Sleep -Milliseconds 200
            }
        }
    } else {
        # 复制非 JPG/PNG 文件
        $OutputFile = Join-Path $OutputSubDir $File.Name
        Copy-Item -Path $File.FullName -Destination $OutputFile -Force
        Write-Host "$RelativePath ===>非 jpg/png，已复制到 $OutputFile"
    }
}

# 等待剩余任务完成并接收输出
$Jobs | Wait-Job | Out-Null
$Jobs | Receive-Job | ForEach-Object { Write-Host $_ }
$Jobs | Remove-Job -Force

Write-Host "全部完成！All completed！"
