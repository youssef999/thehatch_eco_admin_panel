// Free, in-browser background removal for product photos.
// Model: onnx-community/ormbg-ONNX (Apache-2.0, IS-Net CNN) via Transformers.js.
// BiRefNet was dropped: it OOMs in the browser ("model execution: 240595976") and breaks
// WebGPU on many Macs (Invalid ComputePipeline computeSliceOffsets).
// Exposed to Dart as `window.theHatchBg` (see lib/core/services/background_removal_service.dart).

const TRANSFORMERS_URL = 'https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.7.6';
const MODEL_ID = 'onnx-community/ormbg-ONNX';
const ALPHA_THRESHOLD = 24;

let loading = null;
let segmenter = null;

async function loadModel(onProgress) {
  if (segmenter) return segmenter;
  if (loading) return loading;
  loading = (async () => {
    const { pipeline, env } = await import(TRANSFORMERS_URL);
    env.allowLocalModels = false;
    const progress_callback = (event) => {
      if (onProgress && event.status === 'progress' && event.total) {
        onProgress(Math.round((event.loaded / event.total) * 100));
      }
    };
    // WASM only — ormbg WebGPU hits MaxPool limits on some GPUs; WASM is reliable here.
    segmenter = await pipeline('background-removal', MODEL_ID, {
      device: 'wasm',
      dtype: 'fp32',
      progress_callback,
    });
    return segmenter;
  })();
  try {
    return await loading;
  } catch (error) {
    loading = null;
    segmenter = null;
    throw error;
  }
}

function canvasToPng(canvas) {
  return new Promise((resolve, reject) =>
    canvas.toBlob((blob) => (blob ? resolve(blob) : reject(new Error('encode failed'))), 'image/png'),
  );
}

/// Cuts the subject out, then centers it on pure white with [margin] padding.
/// [ratio] is width / height of the output (0.8 = 4:5); 0 keeps the original frame.
async function removeBackground(bytes, options = {}) {
  const ratio = options.ratio ?? 0.8;
  const margin = options.margin ?? 0.08;
  const { RawImage } = await import(TRANSFORMERS_URL);

  await loadModel(options.onProgress);

  const blob = new Blob([bytes]);
  const image = await RawImage.fromBlob(blob);
  const result = await segmenter(image);
  const cutout = Array.isArray(result) ? result[0] : result;
  if (!cutout) throw new Error('no subject found');

  // Pipeline returns RGBA with a transparent background.
  const cut = cutout.toCanvas();
  const width = cut.width;
  const height = cut.height;
  const cutCtx = cut.getContext('2d');
  const pixels = cutCtx.getImageData(0, 0, width, height);

  let minX = width,
    minY = height,
    maxX = -1,
    maxY = -1;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const alpha = pixels.data[(y * width + x) * 4 + 3];
      if (alpha > ALPHA_THRESHOLD) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0) throw new Error('no subject found');

  const boxW = maxX - minX + 1;
  const boxH = maxY - minY + 1;
  let outW = width;
  let outH = height;
  if (ratio > 0) {
    outH = Math.max(boxH, boxW / ratio) / (1 - 2 * margin);
    outW = outH * ratio;
  }
  const scale = Math.min(1, 2400 / Math.max(outW, outH));
  outW = Math.round(outW * scale);
  outH = Math.round(outH * scale);

  const out = document.createElement('canvas');
  out.width = outW;
  out.height = outH;
  const ctx = out.getContext('2d');
  ctx.fillStyle = '#FFFFFF';
  ctx.fillRect(0, 0, outW, outH);
  ctx.imageSmoothingQuality = 'high';
  if (ratio > 0) {
    const drawW = boxW * scale;
    const drawH = boxH * scale;
    ctx.drawImage(cut, minX, minY, boxW, boxH, (outW - drawW) / 2, (outH - drawH) / 2, drawW, drawH);
  } else {
    ctx.drawImage(cut, 0, 0, outW, outH);
  }
  const png = await canvasToPng(out);
  return new Uint8Array(await png.arrayBuffer());
}

window.theHatchBg = {
  removeBackground,
  warmUp: (onProgress) => loadModel(onProgress).then(() => true),
  isLoaded: () => segmenter !== null,
  device: () => 'wasm',
};
