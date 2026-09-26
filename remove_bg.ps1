Add-Type -AssemblyName System.Drawing

$folder = 'c:\Users\Dr.pc\Desktop\harvest_hub\assets\images'
$images = @('harvi.jpg', 'harvi_greeting.jpg', 'harvi_thinking.jpg', 'harvi_talking.jpg', 'harvi_error.jpg')

foreach ($img in $images) {
    $path = Join-Path $folder $img
    if (Test-Path $path) {
        $bmp = [System.Drawing.Bitmap]::FromFile($path)
        $newBmp = New-Object System.Drawing.Bitmap($bmp.Width, $bmp.Height)
        
        # Get background color from top-left pixel
        $bgColor = $bmp.GetPixel(0, 0)
        
        for ($x = 0; $x -lt $bmp.Width; $x++) {
            for ($y = 0; $y -lt $bmp.Height; $y++) {
                $pixel = $bmp.GetPixel($x, $y)
                
                # Calculate color distance
                $diffR = [Math]::Abs($pixel.R - $bgColor.R)
                $diffG = [Math]::Abs($pixel.G - $bgColor.G)
                $diffB = [Math]::Abs($pixel.B - $bgColor.B)
                
                # If color is close to background, make it transparent
                if ($diffR -lt 40 -and $diffG -lt 40 -and $diffB -lt 40) {
                    $newBmp.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
                } else {
                    $newBmp.SetPixel($x, $y, $pixel)
                }
            }
        }
        
        $pngPath = $path -replace '\.jpg$', '.png'
        $newBmp.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        $newBmp.Dispose()
        
        Remove-Item $path
    }
}
