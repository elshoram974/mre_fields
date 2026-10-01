// Records the demo pages of the example app as PNG frames, for the GIFs in
// doc/images. Run it through tool/demo/make_gifs.sh.
//
// Needs Node 22 or newer (global fetch and WebSocket) and Google Chrome started
// with --remote-debugging-port=9333. The example web build must be served, for
// example `cd example/build/web && python3 -m http.server 8765`.
//
//   node tool/demo/record.mjs text  "http://localhost:8765/?demo=text"
//   node tool/demo/record.mjs paste "http://localhost:8765/?demo=paste"
//
// Frames go to $FRAMES_DIR (default /tmp/mre_fields_frames/<scenario>).
import { writeFileSync, mkdirSync, rmSync } from 'node:fs';
const [,, scenario, url] = process.argv;
const outDir = `${process.env.FRAMES_DIR ?? '/tmp/mre_fields_frames'}/${scenario}`;
rmSync(outDir, { recursive: true, force: true }); mkdirSync(outDir, { recursive: true });
const W = 640, H = 520, SCALE = 2;
let CLIP = { x: 64, y: 20, width: 512, height: 340 };
const t = await (await fetch('http://127.0.0.1:9333/json/new?about:blank', { method: 'PUT' })).json();
const ws = new WebSocket(t.webSocketDebuggerUrl);
let id = 0; const pending = new Map();
const send = (m, p = {}) => new Promise((r) => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method: m, params: p })); });
ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result); pending.delete(m.id); } };
await new Promise((r) => (ws.onopen = r));
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
await send('Page.enable');
await send('Emulation.setDeviceMetricsOverride', { width: W, height: H, deviceScaleFactor: 1, mobile: false });
await send('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: 'light' }] });
await send('Emulation.setFocusEmulationEnabled', { enabled: true });
await send('Page.navigate', { url });
await sleep(12000);

const frames = []; // { file, ms }
const snap = async (ms) => {
  const s = await send('Page.captureScreenshot', { format: 'png', clip: { ...CLIP, scale: SCALE } });
  const file = `${outDir}/${String(frames.length).padStart(3, '0')}.png`;
  writeFileSync(file, Buffer.from(s.data, 'base64'));
  frames.push({ file, ms });
};
const click = async (x, y) => { for (const type of ['mousePressed', 'mouseReleased']) await send('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1 }); await sleep(350); };
const away = () => send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: 10, y: 10 });
const type = async (text, msPerChar = 110) => { for (const ch of [...text]) { await send('Input.insertText', { text: ch }); await sleep(120); await snap(msPerChar); } };
const evalJs = (expression) => send('Runtime.evaluate', { expression, awaitPromise: true, userGesture: true, returnByValue: true });
const pasteImage = (hue) => evalJs(`(async()=>{
  const c=document.createElement('canvas');c.width=c.height=240;const x=c.getContext('2d');
  const g=x.createLinearGradient(0,0,240,240);g.addColorStop(0,'hsl(${hue},75%,45%)');g.addColorStop(1,'hsl(${(hue + 50) % 360},85%,70%)');
  x.fillStyle=g;x.fillRect(0,0,240,240);x.fillStyle='rgba(255,255,255,0.85)';x.beginPath();x.arc(120,100,46,0,7);x.fill();
  x.fillStyle='rgba(255,255,255,0.7)';x.fillRect(40,170,160,22);
  const b=await new Promise(r=>c.toBlob(r,'image/png'));
  const dt=new DataTransfer();dt.items.add(new File([b],'photo.png',{type:'image/png'}));
  (document.activeElement||document.body).dispatchEvent(new ClipboardEvent('paste',{clipboardData:dt,bubbles:true,cancelable:true}));
})()`);

if (scenario === 'text') {
  const FIELD = [320, 136], CLEAR = [490, 136];
  await snap(900);
  await click(...FIELD);
  await snap(500);
  for (const [phrase, hold] of [['Hello world', 1300], ['مرحبا بالعالم', 1500], ['123 مرحبا', 1700], ['(#1) Hello', 1700], ['مرحبا Hello 2024', 1700]]) {
    await type(phrase);
    frames[frames.length - 1].ms = hold;
    await click(...CLEAR);
    await away();
    await sleep(300);
    await snap(450);
  }
} else if (scenario === 'phone') {
  // The picker opens as a sheet over the page, so this GIF shows the whole viewport.
  CLIP = { x: 0, y: 0, width: 640, height: 520 };
  const FIELD = [350, 136], CLEAR = [492, 136], DIAL = [160, 136], SEARCH = [320, 166], FIRST_RESULT = [320, 222];
  const clearField = async () => { await click(...CLEAR); await away(); await sleep(300); };
  // A string sent in one piece is what a paste looks like to the field.
  const paste = async (text, hold) => { await send('Input.insertText', { text }); await sleep(600); await snap(hold); };

  await snap(1200);
  await click(...FIELD);
  await snap(400);
  await type('1012345678', 100);
  frames[frames.length - 1].ms = 1600;
  await clearField();
  await snap(450);

  await paste('+966 50 123 4567', 1900);
  await clearField();
  await paste('+20 101', 1900);
  await clearField();

  await click(...DIAL);
  await sleep(700);
  await snap(1000);
  await click(...SEARCH);
  await type('united', 90);
  frames[frames.length - 1].ms = 1100;
  await click(...FIRST_RESULT);
  await sleep(900);
  await snap(900);
  await click(...FIELD);
  await type('501234567', 100);
  frames[frames.length - 1].ms = 1800;
} else if (scenario === 'paste') {
  const FIELD = [320, 150];
  await snap(1000);
  await click(...FIELD);
  await snap(500);
  await type('Look at these');
  frames[frames.length - 1].ms = 700;
  for (const hue of [190, 28, 285]) {
    await pasteImage(hue);
    await sleep(900);
    await snap(1100);
  }
  await snap(900);
}
writeFileSync(`${outDir}/frames.json`, JSON.stringify(frames));
console.log(scenario, 'frames', frames.length);
process.exit(0);
