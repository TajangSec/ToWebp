# ָ�� cwebp.exe ·��
$CWebpPath = "����·����Absolute path��"

# ָ������Ŀ¼������ JPG �� PNG ͼƬ��
$InputDir = "����·����Absolute path��"

# ָ�����Ŀ¼
$OutputDir = "����·����Absolute path��"

# �߳�������
$MaxThreads = 8

# ȷ�����Ŀ¼����
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# ��ȡ�����ļ�
$Files = Get-ChildItem -Path $InputDir -File -Recurse

# �̹߳���
$Jobs = New-Object System.Collections.ArrayList
foreach ($File in $Files) {
    # �������·����������Ӧ����Ŀ¼
    $RelativePath = $File.FullName.Substring($InputDir.Length).TrimStart('\')
    $OutputSubDir = Split-Path (Join-Path $OutputDir $RelativePath) -Parent
    if (!(Test-Path $OutputSubDir)) {
        New-Item -ItemType Directory -Path $OutputSubDir | Out-Null
    }

    # ����Ƿ�Ϊ JPG/PNG �ļ�
    if ($File.Extension -match "\.jpg|\.png") {
        # ����������
        $Job = Start-Job -ScriptBlock {
            param ($CWebpPath, $InputFile, $OutputSubDir, $BaseName, $RelativePath)

            # ���� WebP ����ļ�·��
            $BaseOutputFile = Join-Path $OutputSubDir ("$BaseName.webp")
            $OutputFile = $BaseOutputFile

            # ���������ļ�
            $Counter = 1
            while (Test-Path $OutputFile) {
                $OutputFile = Join-Path $OutputSubDir ("$BaseName ($Counter).webp")
                $Counter++
            }

            # ��¼��������־
            if ($OutputFile -ne $BaseOutputFile) {
                Write-Output "$RelativePath ===>ת��ʱ����ͬ���ļ�����������Ϊ $(Split-Path -Leaf $OutputFile)"
            }

            # ���� cwebp ת���������Ա�׼���
            & $CWebpPath $InputFile -o $OutputFile 2>&1 | Out-Null

        } -ArgumentList $CWebpPath, $File.FullName, $OutputSubDir, $File.BaseName, $RelativePath

        # �����ҵ���б�
        [void]$Jobs.Add($Job)

        # �����߳���
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
        # ���Ʒ� JPG/PNG �ļ�
        $OutputFile = Join-Path $OutputSubDir $File.Name
        Copy-Item -Path $File.FullName -Destination $OutputFile -Force
        Write-Host "$RelativePath ===>�� jpg/png���Ѹ��Ƶ� $OutputFile"
    }
}

# �ȴ�ʣ��������ɲ��������
$Jobs | Wait-Job | Out-Null
$Jobs | Receive-Job | ForEach-Object { Write-Host $_ }
$Jobs | Remove-Job -Force

Write-Host "ȫ����ɣ�All completed��"
