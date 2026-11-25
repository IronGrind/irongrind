$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Speech
$voice=[System.Speech.Synthesis.SpeechSynthesizer]::new()
$voice.Rate=-1
$ff='C:/Program Files/Streamlabs OBS/resources/app.asar.unpacked/node_modules/obs-studio-node/ffmpeg.exe'
$folder=Join-Path (Split-Path $PSScriptRoot) 'Documentations/Defense'
$reference=Join-Path $folder 'IronGrind ERD Defense Explanation.mp4'
$culture=[Globalization.CultureInfo]::InvariantCulture
$scenes=([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'story.txt')).Trim() -split '\r?\n\s*\r?\n')
$font=[Drawing.Font]::new('Segoe UI',27,[Drawing.FontStyle]::Bold,[Drawing.GraphicsUnit]::Pixel)
$titleFont=[Drawing.Font]::new('Segoe UI',35,[Drawing.FontStyle]::Bold,[Drawing.GraphicsUnit]::Pixel)
$ink=[Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(20,36,51))
$paper=[Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(247,250,253))
$format=[Drawing.StringFormat]::new()
$format.Alignment=[Drawing.StringAlignment]::Center
$format.LineAlignment=[Drawing.StringAlignment]::Center
$manifest=@()
$sceneNumber=0
foreach($scene in $scenes){
  $sceneNumber++
  $lines=$scene -split '\r?\n'
  $at,$title=$lines[0] -split '\|',2
  $still=Join-Path $PSScriptRoot 'still.png'
  & $ff -hide_banner -loglevel error -y -ss $at -i $reference -frames:v 1 -threads 1 $still
  if($LASTEXITCODE){throw "Could not extract scene $sceneNumber"}
  $original=[Drawing.Image]::FromFile($still)
  $base=[Drawing.Bitmap]::new(1440,810)
  $g=[Drawing.Graphics]::FromImage($base)
  $g.FillRectangle($paper,0,0,1440,810)
  $g.DrawImageUnscaled($original,80,0)
  $original.Dispose()
  $g.TextRenderingHint=[Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.FillRectangle($ink,80,39,1280,64)
  $g.DrawString($title,$titleFont,[Drawing.Brushes]::White,105,44)
  $g.Dispose()
  foreach($paragraph in $lines[1..($lines.Count-1)]){
    $paragraph=$paragraph.Replace(' I D',' ID')
    $wrapped=@()
    $line=''
    foreach($word in ($paragraph -split ' ')){
      if($line -and $line.Length+$word.Length+1 -gt 62){$wrapped+=$line;$line=''}
      if($line){$line+=' '}
      $line+=$word
    }
    if($line){$wrapped+=$line}
    for($j=0;$j -lt $wrapped.Count;$j+=2){
      $caption=$wrapped[$j..([Math]::Min($j+1,$wrapped.Count-1))] -join "`n"
      $stem='cue-{0:000}' -f ($manifest.Count+1)
      $frame=Join-Path $PSScriptRoot "$stem.png"
      $wav=Join-Path $PSScriptRoot "$stem.wav"
      $bmp=$base.Clone()
      $g=[Drawing.Graphics]::FromImage($bmp)
      $g.TextRenderingHint=[Drawing.Text.TextRenderingHint]::AntiAliasGridFit
      $width=[Math]::Ceiling($g.MeasureString($caption,$font).Width)+52
      $rect=[Drawing.RectangleF]::new((1440-$width)/2,723,$width,78)
      $g.FillRectangle($ink,$rect)
      $g.DrawString($caption,$font,[Drawing.Brushes]::White,$rect,$format)
      $bmp.Save($frame,[Drawing.Imaging.ImageFormat]::Png)
      $g.Dispose()
      $bmp.Dispose()
      $voice.SetOutputToWaveFile($wav)
      $voice.Speak($caption.Replace("`n",' '))
      $voice.SetOutputToNull()
      & $ff -hide_banner -loglevel error -y -loop 1 -framerate 12 -i $frame -i $wav -af 'volume=-2dB,apad=pad_dur=0.3' -shortest -c:v libx264 -preset ultrafast -tune stillimage -threads 3 -pix_fmt yuv420p -c:a aac -ar 44100 -ac 1 (Join-Path $PSScriptRoot "$stem.mp4")
      if($LASTEXITCODE){throw "Encoding failed for $stem"}
      $manifest+="file '$stem.mp4'"
    }
  }
  $base.Dispose()
  Write-Output "Rendered scene $sceneNumber of $($scenes.Count)"
}
$voice.Dispose()
$list=Join-Path $PSScriptRoot 'cues.txt'
[IO.File]::WriteAllLines($list,$manifest,[Text.Encoding]::ASCII)
& $ff -hide_banner -loglevel error -y -f concat -safe 1 -i $list -c copy -movflags +faststart (Join-Path $PSScriptRoot 'detailed.mp4')
if($LASTEXITCODE){throw 'Final MP4 assembly failed'}
