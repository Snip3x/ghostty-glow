# ghostty-glow

A soft, even text glow shader for [Ghostty](https://ghostty.org).

Most glow / bloom shaders pick what to light up by **luma** (perceived brightness).
That makes greens and whites glow, but blues, reds and oranges barely glow at all,
even when they're fully saturated. This one uses the **brightest colour channel**
instead and normalises the glow colour. Every coloured glyph gets the same glow,
and only black and dark greys stay unlit.

<!-- screenshot: put an image at assets/preview.png and uncomment
![preview](assets/preview.png)
-->

## Features

- Even glow for every hue: blue, orange and red glow as much as green and white
- Smooth Gaussian falloff with no grain or banding
- Letters stay crisp; the glow is only added *around* glyphs
- Works with transparent / blurred backgrounds (`background-opacity`)
- Static, so no animation loop or idle GPU usage (`custom-shader-animation = false` is fine)
- Optional matching **Glow Forest** colour theme

## Install

```sh
git clone https://github.com/Snip3x/ghostty-glow
cd ghostty-glow
./install.sh
```

Then add the following to your Ghostty config (`~/.config/ghostty/config`):

```ini
custom-shader = ~/.config/ghostty/shaders/glow.glsl

# optional matching theme
theme = glow-forest
```

Reload the config (`ctrl+shift+,` by default) or open a new window.

### Manual

Copy `shaders/glow.glsl` anywhere and point `custom-shader` at it.

## Tuning

Edit the constants at the top of `glow.glsl`:

| Constant   | Default | What it does |
|------------|---------|--------------|
| `STRENGTH` | `0.20`  | Glow intensity. `0.15` is subtle, `0.4` and up is very bright. |
| `SPREAD`   | `1.7`   | How far the glow reaches (pixels between samples). |
| `LOW`      | `0.40`  | Colours dimmer than this don't glow. Lower it to make greys glow too. |
| `HIGH`     | `0.65`  | Colours at or above this get full glow. |
| `R`        | `8`     | Blur radius in samples. Lower (e.g. `5`) is cheaper on weak GPUs. |

The glow fades out evenly from the text. To make the fade tighter or looser, change
the `sigma` multiplier (`0.35`) in `mainImage`.

## Performance

The blur samples a `(2R+1)²` grid (289 samples at `R = 8`) per pixel. That's
trivial for any discrete GPU. On integrated graphics with a large window, drop `R`
to 5 or 6.

## License

MIT
