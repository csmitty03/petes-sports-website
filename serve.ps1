$root = $PSScriptRoot
$port = 8081
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/"

$mimes = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.js'   = 'application/javascript; charset=utf-8'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.svg'  = 'image/svg+xml'
    '.ico'  = 'image/x-icon'
    '.webp' = 'image/webp'
}

while ($listener.IsListening) {
    $response = $null
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.LocalPath
        if ([string]::IsNullOrWhiteSpace($path) -or $path -eq '/') {
            $path = '/index.html'
        }

        $relative = $path.TrimStart('/').Replace('/', [IO.Path]::DirectorySeparatorChar)
        $file = Join-Path $root $relative

        if (Test-Path $file -PathType Leaf) {
            $ext = [IO.Path]::GetExtension($file).ToLower()
            $response.ContentType = if ($mimes.ContainsKey($ext)) { $mimes[$ext] } else { 'application/octet-stream' }
            $bytes = [IO.File]::ReadAllBytes($file)
            $response.StatusCode = 200
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $msg = [Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
            $response.ContentType = 'text/plain; charset=utf-8'
            $response.ContentLength64 = $msg.Length
            $response.OutputStream.Write($msg, 0, $msg.Length)
        }
    } catch {
        Write-Host "Request error: $_"
    } finally {
        if ($null -ne $response) { $response.Close() }
    }
}