function Start-Matrix {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Color = "AAAAAA",
        
        [Parameter(Position=1)]
        [ValidateRange(1,10)]
        [int]$Speed = 5
    )

    # Global variables
    $script:rand = $null
    $script:ScreenWidth = 0
    $script:ScreenHeight = 0
    $script:PossibleGlyphs = $null
    $script:glyphCount = 0
    $script:e = [char]27
    $script:MainColor = 0
    $script:ColorVariations = @()
    $script:AllGlyphs = $null
    $script:originalBG = $null
    $script:originalFG = $null

    class Glyph {
        [int]$LastPosition
        [int]$CurrentPosition
        [int]$Velocity
        [int]$Intensity
        [double]$IntensityChange
        [char]$Current
        [char]$Last
        [bool]$IsActive
        [bool]$NeedsClear
        [bool]$IsHead  # New property to track head of column
        
        Glyph([string]$customChar) {
            $this.Setup($customChar)
        }

        [void]Setup([string]$customChar) {
            $this.CurrentPosition = $script:rand.Next(-$script:ScreenHeight, -5)
            # Modified velocity calculation - uses fixed base speed with Speed parameter as multiplier
            $baseSpeed = 1
            $this.Velocity = [Math]::Max(1, $baseSpeed + ($script:rand.NextDouble() * 0.5) * ($script:Speed / 5))
            $this.Intensity = 0
            $this.IntensityChange = ($script:rand.Next(5, 12) / 100)
            $this.Current = if ($customChar) { $customChar[0] } else { $script:PossibleGlyphs[$script:rand.Next($script:glyphCount)] }
            $this.Last = if ($customChar) { $customChar[0] } else { $script:PossibleGlyphs[$script:rand.Next($script:glyphCount)] }
            $this.IsActive = $true
            $this.NeedsClear = $false
            $this.IsHead = $false
        }

        [void]Move([string]$customChar) {
            $this.LastPosition = $this.CurrentPosition
            $this.Intensity += [Math]::Floor(255 * $this.IntensityChange)
            if ($this.Intensity -gt 255) { $this.Intensity = 255 }

            $this.CurrentPosition += $this.Velocity
            
            $this.Last = $this.Current
            if ($this.Current -ne ' ') { 
                $this.Current = if ($customChar) { $customChar[0] } else { $script:PossibleGlyphs[$script:rand.Next($script:glyphCount)] }
            }
            
            # Mark for clearing when trail extends beyond screen
            if ($this.LastPosition -ge $script:ScreenHeight) {
                $this.NeedsClear = $true
            }
            
            # Reset when reaching bottom
            if ($this.CurrentPosition -gt $script:ScreenHeight + $this.Velocity) {
                $this.IsActive = $false
                $this.Setup($customChar)
            }
        }
    }

    function Convert-RGBToANSI {
        param([System.Drawing.Color]$color)
        
        $closestIndex = 16
        $minDistance = [Double]::MaxValue
        
        for ($r = 0; $r -lt 6; $r++) {
            for ($g = 0; $g -lt 6; $g++) {
                for ($b = 0; $b -lt 6; $b++) {
                    $index = 16 + ($r * 36) + ($g * 6) + $b
                    $ansiR = if ($r -eq 0) { 0 } else { ($r * 40) + 55 }
                    $ansiG = if ($g -eq 0) { 0 } else { ($g * 40) + 55 }
                    $ansiB = if ($b -eq 0) { 0 } else { ($b * 40) + 55 }
                    
                    $distance = [Math]::Sqrt(
                        [Math]::Pow(($ansiR - $color.R), 2) +
                        [Math]::Pow(($ansiG - $color.G), 2) +
                        [Math]::Pow(($ansiB - $color.B), 2)
                    )
                    
                    if ($distance -lt $minDistance) {
                        $minDistance = $distance
                        $closestIndex = $index
                    }
                }
            }
        }
        
        return $closestIndex
    }

    function Get-LighterColor {
        param([int]$baseColorIndex)
        
        # Convert index back to RGB
        $baseColorIndex -= 16
        $r = [Math]::Floor($baseColorIndex / 36)
        $g = [Math]::Floor(($baseColorIndex % 36) / 6)
        $b = $baseColorIndex % 6
        
        # Lighten each component
        $r = [Math]::Min(5, $r + 1)
        $g = [Math]::Min(5, $g + 1)
        $b = [Math]::Min(5, $b + 1)
        
        return 16 + ($r * 36) + ($g * 6) + $b
    }

    function Update-ScreenDimensions {
        $script:ScreenWidth = $host.UI.RawUI.WindowSize.Width
        $script:ScreenHeight = $host.UI.RawUI.WindowSize.Height
    }

    function Initialize-Script {
        param(
            [string]$HexColor
        )
        
        $script:rand = [System.Random]::new()
        # Changed this line to just store the speed parameter without modification
        $script:Speed = $Speed
        Update-ScreenDimensions
        
        [char[]]$script:PossibleGlyphs = @(
            " ", " ", " ", " ", "+", "=", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
            "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "<", ">", "?", "{", "}", "[", "]",
            "~", "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ",
            "タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "マ",
            "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ワ", "ヲ", "ン"
        )
        $script:glyphCount = $script:PossibleGlyphs.Count
        
        $r = [Convert]::ToInt32($HexColor.Substring(0,2), 16)
        $g = [Convert]::ToInt32($HexColor.Substring(2,2), 16)
        $b = [Convert]::ToInt32($HexColor.Substring(4,2), 16)
        
        $script:MainColor = Convert-RGBToANSI ([System.Drawing.Color]::FromArgb($r, $g, $b))
        $script:HeadColor = Get-LighterColor $script:MainColor  # Lighter color for head
        
        # Create color variations for the trail
        $script:ColorVariations = @()
        for ($i = -2; $i -le 2; $i++) {
            if ($i -ne 0) {
                $vr = [Math]::Max(0, [Math]::Min(255, $r + ($i * 15)))
                $vg = [Math]::Max(0, [Math]::Min(255, $g + ($i * 15)))
                $vb = [Math]::Max(0, [Math]::Min(255, $b + ($i * 15)))
                $script:ColorVariations += Convert-RGBToANSI ([System.Drawing.Color]::FromArgb($vr, $vg, $vb))
            }
        }
        
        $script:AllGlyphs = [Glyph[]]::new($script:ScreenWidth)
        for ($i = 0; $i -lt $script:AllGlyphs.Count; $i++) {
            if ($i % 2 -eq 0) {
                $script:AllGlyphs[$i] = [Glyph]::new($null)
                $script:AllGlyphs[$i].IsHead = $true  # Mark as head initially
            }
        }
        
        [Console]::CursorVisible = $false
        $script:originalBG = [Console]::BackgroundColor
        $script:originalFG = [Console]::ForegroundColor
        
        Write-Host "$($script:e)[48;5;16m$($script:e)[2J$($script:e)[H" -NoNewline
        [Console]::BackgroundColor = [ConsoleColor]::Black
        [Console]::ForegroundColor = [ConsoleColor]::Black
        Clear-Host
    }

    function Cleanup {
        Write-Host "$($script:e)[0m$($script:e)[2J$($script:e)[H" -NoNewline
        [Console]::BackgroundColor = $script:originalBG
        [Console]::ForegroundColor = $script:originalFG
        [Console]::CursorVisible = $true
        Clear-Host
    }

    # Main execution
    try {
        Initialize-Script -HexColor $Color
        
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $lastWidth = $script:ScreenWidth
        $lastHeight = $script:ScreenHeight
        
        # Clear the entire screen
        Write-Host "$($script:e)[2J" -NoNewline
        
        while (-not [System.Console]::KeyAvailable) {
            Update-ScreenDimensions
            if ($lastWidth -ne $script:ScreenWidth -or $lastHeight -ne $script:ScreenHeight) {
                $lastWidth = $script:ScreenWidth
                $lastHeight = $script:ScreenHeight
                Write-Host "$($script:e)[2J" -NoNewline
            
                # Recreate glyphs based on new size
                $script:AllGlyphs = [Glyph[]]::new($script:ScreenWidth)
                for ($i = 0; $i -lt $script:AllGlyphs.Count; $i++) {
                    if ($i % 2 -eq 0) {
                        $script:AllGlyphs[$i] = [Glyph]::new($null)
                        $script:AllGlyphs[$i].IsHead = $true
                    }
                }
            }
            
            # Modified frame timing - uses Speed parameter to control update frequency
            $frameDelay = 100 / $Speed  # Higher speed = more frequent updates
            if ($stopwatch.Elapsed.TotalMilliseconds -gt $frameDelay) {
                $outputBuffer = [System.Text.StringBuilder]::new()
                
                for ($i = 0; $i -lt $script:ScreenWidth; $i++) {
                    if ($i -ge $script:AllGlyphs.Count -or $null -eq $script:AllGlyphs[$i]) { continue }
                    
                    $glyph = $script:AllGlyphs[$i]
                    $glyph.Move($null)

                    # Clear old trail ends
                    if ($glyph.NeedsClear -and $glyph.LastPosition -ge 0) {
                        $clearPos = [Math]::Floor($glyph.LastPosition)
                        if ($clearPos -lt $script:ScreenHeight) {
                            $outputBuffer.Append("$($script:e)[$($clearPos);$($i)H ") | Out-Null
                        }
                        $glyph.NeedsClear = $false
                    }

                    # Draw current position (head in lighter color)
                    if ($glyph.IsActive -and $glyph.CurrentPosition -ge 0 -and $glyph.CurrentPosition -lt $script:ScreenHeight) {
                        $yPos = [Math]::Floor($glyph.CurrentPosition)
                        $color = if ($glyph.IsHead) { $script:HeadColor } else { $script:MainColor }
                        $outputBuffer.Append("$($script:e)[$($yPos);$($i)H$($script:e)[38;5;${color}m$($glyph.Current)") | Out-Null
                    }

                    # Draw fading trail
                    if ($glyph.LastPosition -ge 0 -and $glyph.LastPosition -lt $script:ScreenHeight) {
                        $yPos = [Math]::Floor($glyph.LastPosition)
                        $trailColor = $script:ColorVariations[$script:rand.Next($script:ColorVariations.Length)]
                        $outputBuffer.Append("$($script:e)[$($yPos);$($i)H$($script:e)[38;5;${trailColor}m$($glyph.Last)") | Out-Null
                    }
                }
                
                [Console]::Write($outputBuffer.ToString())
                $stopwatch.Restart()
            }
        }
    } finally {
        Cleanup
        if ([System.Console]::KeyAvailable) {
            $null = [Console]::ReadKey($true)
        }
    }
}

Set-Alias -Name matrix -Value Start-Matrix -Description "Matrix screen animation"

Export-ModuleMember -Function Start-Matrix
Export-ModuleMember -Alias matrix