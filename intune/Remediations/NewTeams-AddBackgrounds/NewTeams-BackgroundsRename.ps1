#Directory where your images are stored (Change Accordingly)
$backgroundsdir = "C:\temp\TeamsBackgrounds"
$renamedbackgrounds = New-Item -Path "$backgroundsdir" -Name RenamedBackgrounds -ItemType Directory -Force

#Rename JPEG files
$jpegimages = get-childitem $backgroundsdir -filter "*.jpeg"
foreach ($jpegimage in $jpegimages)
{
$uuid = new-guid
$name = "$uuid.jpeg"
$thumbname = "${uuid}_thumb.jpeg"
$newnamedestination = Join-Path -Path $renamedbackgrounds -ChildPath $name
$newthumbdestination = Join-Path -Path $renamedbackgrounds -ChildPath $thumbname
Copy-Item -Path $jpegimage.FullName -Destination $newnamedestination
Copy-Item -Path $jpegimage.FullName -Destination $newthumbdestination
}

#Rename JPG Files
$jpgimages = get-childitem $backgroundsdir -filter "*.jpg"
foreach ($jpgimage in $jpgimages)
{
$uuid = new-guid
$name = "$uuid.jpg"
$thumbname = "${uuid}_thumb.jpg"
$newnamedestination = Join-Path -Path $renamedbackgrounds -ChildPath $name
$newthumbdestination = Join-Path -Path $renamedbackgrounds -ChildPath $thumbname
Copy-Item -Path $jpgimage.FullName -Destination $newnamedestination
Copy-Item -Path $jpgimage.FullName -Destination $newthumbdestination
}

#Rename PNG Files
$pngimages = get-childitem $backgroundsdir -filter "*.png"
foreach ($pngimage in $pngimages)
{
$uuid = new-guid
$name = "$uuid.png"
$thumbname = "${uuid}_thumb.png"
$newnamedestination = Join-Path -Path $renamedbackgrounds -ChildPath $name
$newthumbdestination = Join-Path -Path $renamedbackgrounds -ChildPath $thumbname
Copy-Item -Path $pngimage.FullName -Destination $newnamedestination
Copy-Item -Path $pngimage.FullName -Destination $newthumbdestination
}

#Rename BMP Files
$bmpimages = get-childitem $backgroundsdir -filter "*.bmp"
foreach ($bmpimage in $bmpimages)
{
$uuid = new-guid
$name = "$uuid.bmp"
$thumbname = "${uuid}_thumb.bmp"
$newnamedestination = Join-Path -Path $renamedbackgrounds -ChildPath $name
$newthumbdestination = Join-Path -Path $renamedbackgrounds -ChildPath $thumbname
Copy-Item -Path $bmpimage.FullName -Destination $newnamedestination
Copy-Item -Path $bmpimage.FullName -Destination $newthumbdestination
}