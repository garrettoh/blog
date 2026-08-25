---
title: "03 - Pretty Devilish File"
layout: "Notes"
overview: "Carving a tiny JPEG from a PDF and decoding its red-channel pixels into the flag."
status: "Draft complete"
---

## Overview

The challenge arrived as a PDF, so I began with document triage. `pdfid` reported eight objects, including comments and streams worth investigating. I then used `pdf-parser`, qpdf, and a small zlib carver to enumerate the objects, try an empty-password decryption pass, and extract compressed data.

That first pass produced one extracted object, one carved zlib stream, and a decrypted copy of the PDF, but none contained an obvious flag. The useful clue appeared when I returned to the decrypted file's raw bytes: a JPEG header (`FF D8`) was present near the text `Flare-On!`.

## Carving the hidden image

I copied the byte range from the JPEG start marker (`FF D8`) through its end marker (`FF D9`) and saved it as a new image. The result was valid, but unusually small: only 37 pixels wide and one pixel high. There was no useful picture to inspect, which suggested the pixel values themselves were the payload.

## Decoding the pixels

I converted the image to RGB, selected the red value from every pixel, and interpreted printable values as ASCII:

```python
from PIL import Image
import numpy as np

image = Image.open("devilish.jpg").convert("RGB")
pixels = np.array(image)
red_values = pixels[:, :, 0].flatten()

flag = "".join(chr(value) for value in red_values if 32 <= value <= 126)
print(flag)
```

The 37 red-channel values decode directly into the challenge flag.

![The pixel decoder reports a 37-by-1 image and prints the recovered flag.](/images/flareon-12/03-pretty-devilish-file/pixel-decoder-output.png)

## Flag

```text
Puzzl1ng-D3vilish-F0rmat@flare-on.com
```
