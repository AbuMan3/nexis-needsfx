const playbacks = new Map();
let audioContext = null;

function getAudioContext() {
    if (!audioContext) {
        audioContext = new (window.AudioContext || window.webkitAudioContext)();
        const listener = audioContext.listener;

        if (listener.positionX) {
            listener.positionX.value = 0;
            listener.positionY.value = 0;
            listener.positionZ.value = 0;
            listener.forwardX.value = 0;
            listener.forwardY.value = 1;
            listener.forwardZ.value = 0;
            listener.upX.value = 0;
            listener.upY.value = 0;
            listener.upZ.value = 1;
        } else {
            listener.setPosition(0, 0, 0);
            listener.setOrientation(0, 1, 0, 0, 0, 1);
        }
    }

    if (audioContext.state === 'suspended') {
        audioContext.resume().catch(() => {});
    }

    return audioContext;
}

function setPosition(panner, x, y, z) {
    if (panner.positionX) {
        panner.positionX.value = x;
        panner.positionY.value = y;
        panner.positionZ.value = z;
    } else {
        panner.setPosition(x, y, z);
    }
}

function cleanup(id, notify = true) {
    const playback = playbacks.get(id);
    if (!playback) return;

    playbacks.delete(id);

    try {
        playback.audio.pause();
        playback.source.disconnect();
        playback.panner.disconnect();
        playback.gain.disconnect();
    } catch (_) {}

    if (notify) {
        fetch(`https://${GetParentResourceName()}/audioEnded`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id })
        }).catch(() => {});
    }
}

function playSpatial(data) {
    if (!data.id || !data.file) return;

    const context = getAudioContext();
    const audio = new Audio(`audio/${encodeURIComponent(data.file)}.ogg`);
    audio.preload = 'auto';

    const source = context.createMediaElementSource(audio);
    const panner = context.createPanner();
    const gain = context.createGain();

    panner.panningModel = 'HRTF';
    panner.distanceModel = 'linear';
    panner.refDistance = 1;
    panner.maxDistance = 10000;
    panner.rolloffFactor = 0;

    setPosition(panner, Number(data.x) || 0, Number(data.y) || 1, Number(data.z) || 0);
    gain.gain.value = Math.max(0, Math.min(1, Number(data.volume) || 0));

    source.connect(panner);
    panner.connect(gain);
    gain.connect(context.destination);

    playbacks.set(data.id, { audio, source, panner, gain });

    audio.addEventListener('ended', () => cleanup(data.id), { once: true });
    audio.addEventListener('error', () => cleanup(data.id), { once: true });
    audio.play().catch(() => cleanup(data.id));
}

function updateSpatial(data) {
    const playback = playbacks.get(data.id);
    if (!playback) return;

    setPosition(
        playback.panner,
        Number(data.x) || 0,
        Number(data.y) || 1,
        Number(data.z) || 0
    );

    const target = Math.max(0, Math.min(1, Number(data.volume) || 0));
    const context = getAudioContext();
    playback.gain.gain.cancelScheduledValues(context.currentTime);
    playback.gain.gain.setTargetAtTime(target, context.currentTime, 0.035);
}

window.addEventListener('message', (event) => {
    const data = event.data || {};

    if (data.action === 'playSpatial') {
        playSpatial(data);
        return;
    }

    if (data.action === 'updateSpatial') {
        updateSpatial(data);
        return;
    }

    if (data.action === 'stopSpatial') {
        cleanup(data.id, false);
    }
});
