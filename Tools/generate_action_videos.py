import argparse
import json
import os
import time
import urllib.error
import urllib.request
from pathlib import Path

BASE_URL = "https://openrouter.ai/api/v1"
OUT_DIR = Path("Art/VideoReferences")

ACTIONS = {
    "Idle": "Subtle breathing idle. Spear held steady, wings relaxed, tiny cloth and feather motion only.",
    "Walk": "Stable walk cycle to the right. Feet alternate cleanly on one baseline, body does not drift.",
    "Attack_01": "Quick forward spear jab. Anticipation pullback, sharp thrust, one readable impact frame, recover to idle.",
    "Hit": "Small damage reaction. Torso flinches back, wings twitch, feet stay planted, recover to idle.",
    "Death": "Defeated collapse. Knees buckle, spear lowers, body falls into a clear final pose on the baseline.",
    "Spawn": "Materialize onto the baseline. Wings unfurl slightly, spear settles, end in idle-ready stance.",
    "Ready": "Enter battle-ready pose. Spear raises, knees bend, wings tighten, final pose returns easily to idle.",
    "Idle_Combat": "Combat idle loop. Guarded stance, spear angled forward, controlled breathing, no position drift.",
    "Run": "Fast run cycle to the right. Strong readable leg motion, spear carried inside frame, feet stay on baseline.",
    "Attack_02": "Sweeping spear slash. Anticipation windup, horizontal strike, one clear impact frame, recover.",
    "Attack_Heavy": "Heavy overhead spear smash. Big anticipation, downward strike, readable impact frame, slow recovery.",
    "Skill_Cast": "Begin magical Thai Garuda skill cast. Spear plants, wings open, body readable, subtle aura only.",
    "Skill_Release": "Release a focused golden energy burst from spear tip. Body remains visible, VFX does not cover silhouette.",
    "Skill_Recover": "Recover from skill release. Aura fades, spear returns to guard, final pose compatible with idle.",
    "Hit_Light": "Light hit reaction. Quick shoulder recoil, brief wing twitch, recover immediately.",
    "Hit_Heavy": "Heavy hit reaction. Strong backward stagger, spear dips, one foot slides but baseline remains clear.",
    "Knockback": "Pushed backward by impact. Body leans back, feet skid on baseline, recover into guarded pose.",
    "Stun": "Stunned loop. Wobbly knees, lowered spear, small wing tremble, no drifting.",
    "Victory": "Short victory pose. Spear lifted proudly, wings flare, settle into a readable hero pose.",
    "Despawn": "Fade or lift away cleanly. Wings fold, body disappears without changing costume or proportions.",
    "TurnAround": "Turn in place from facing right to facing left and back-ready pose, feet remain on baseline.",
    "Guard": "Raise defensive guard. Spear held diagonally, wings tuck behind body, clear shield-like silhouette.",
    "Block": "Block incoming hit with spear. Brace, one impact frame, slight recoil, recover.",
    "Dodge": "Quick evasive step backward. Body ducks, wings compact, feet return to same baseline.",
    "Parry": "Precise spear parry. Small anticipation, sharp deflection motion, crisp recovery.",
    "Charge": "Charge forward attack preparation. Lean forward, spear aimed ahead, controlled acceleration pose.",
    "Taunt": "Confident taunt. Spear flourish, chin up, wings flick, no camera movement.",
    "Buff": "Self-buff pose. Golden Thai pattern aura appears around body edges, silhouette remains readable.",
    "Debuff": "Weakened pose. Purple-gray aura, body slumps slightly, costume unchanged.",
    "Heal": "Healing pose. Warm green-gold light rises subtly, spear grounded, body visible.",
    "Revive": "Rise from downed pose to standing. Wings help lift, spear returns to hand, end idle-ready.",
    "Sleep": "Sleep loop. Drowsy standing slump, spear lowered safely, minimal motion.",
    "Freeze": "Frozen reaction. Body stiffens, icy overlay stays thin, silhouette and weapon remain visible.",
    "Burn": "Burning damage loop. Small flame flickers around edges only, body and wings remain visible.",
    "Poison": "Poison damage loop. Subtle green fumes around feet and spear, no silhouette coverage.",
    "Transform": "Short transformation start. Wings flare and aura pulses, costume must not change during this shot.",
    "Evolve": "Power-up evolution pose. Golden aura expands, body remains same character and proportions.",
    "Summon": "Summoning gesture. Spear traces a small Thai sigil near ground, VFX does not cover body.",
    "Cast_Loop": "Looping spell cast hold. Spear raised, wings open, stable body, first and last frame compatible.",
    "Channeling": "Continuous channeling loop. Energy flows to spear tip, character steady on baseline.",
    "Exhausted": "Exhausted idle. Heavy breathing, lowered spear, wings droop, feet planted.",
    "Intro": "Short entrance intro. Step into frame-ready stance, wings flare once, end on baseline.",
    "Roar": "Garuda battle roar. Chest forward, wings spread, spear held inside frame, recover.",
    "PhaseChange": "Boss phase change. Aura pulse, wings open wide, stance becomes more aggressive without costume change.",
    "Ultimate_Start": "Ultimate attack windup. Deep anticipation, spear draws back, wings fully open, no VFX cover.",
    "Ultimate_Loop": "Ultimate charge loop. Golden energy gathers at spear, stable pose, compatible first and last frame.",
    "Ultimate_Impact": "Ultimate strike impact. Spear slams forward, one very clear impact frame, body readable.",
    "Ultimate_End": "Ultimate recovery. Energy fades, spear lowers back into battle stance.",
    "Enrage": "Enrage animation. Red-gold aura, aggressive stance, wings snap open, no morphing.",
    "ArmorBreak": "Armor break reaction. Brief stagger and small gold fragments, costume remains consistent.",
    "Downed": "Fall into downed-but-alive pose. Spear beside body, final pose readable on baseline.",
    "Execute": "Finishing thrust. Strong anticipation, decisive spear strike, one clear impact frame, controlled recovery.",
    "BossDeath": "Large boss-style defeat collapse. Wings fail, spear drops, body settles into final pose.",
    "BossDeathExplosion": "Defeat with contained golden burst. Explosion behind character, silhouette visible, final body pose readable.",
}

LOOPS = {"Idle", "Walk", "Idle_Combat", "Run", "Stun", "Sleep", "Burn", "Poison", "Cast_Loop", "Channeling", "Exhausted", "Ultimate_Loop"}
ATTACKS = {"Attack_01", "Attack_02", "Attack_Heavy", "Skill_Release", "Block", "Parry", "Ultimate_Impact", "Execute"}


def prompt_for(action):
    kind = "loop" if action in LOOPS else "attack" if action in ATTACKS else "one-shot action"
    return f"""Create a 2D side-view game animation reference video for GAME SIAM IDLE.

Style:
Thai fantasy 2D lane-defense game. Side-view only. Fixed camera. No zoom. No pan. No rotation.
No text. No UI. No watermark. 16:9 landscape. Clean readable silhouette. Game animation reference.
Character scale must remain consistent. Feet must stay on one ground baseline.
Weapon and wings must stay inside the frame. No extra limbs. No character morphing.
No costume changes during the shot. No heavy motion blur.

Character:
A Thai fantasy Garuda warrior / Siamese spear warrior facing right, full body visible,
standing on a fixed baseline, designed for Unity 2D gameplay animation reference.
Gold Thai armor accents, Garuda wings folded or moving naturally, long spear, heroic Siamese fantasy styling.

Action to generate:
{action}

Action description:
{ACTIONS[action]}

Timing:
Keep the shot short, {kind}, 1 to 3 seconds only. Clear anticipation, main action, impact if any, and recovery.
The final pose should be easy to return to Idle.

If the action is an attack:
Show anticipation, show strike, show one clear impact frame, show recovery.
Do not let VFX cover the body. Hit moment must be readable.

If the action is a loop:
Make the first and last frame visually compatible. Keep movement stable. Avoid drifting position.
"""


def request_json(method, url, api_key, payload=None):
    data = None if payload is None else json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://game-siam-idle.local",
            "X-Title": "GAME SIAM IDLE Action References",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as res:
            return json.loads(res.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"{e.code} {e.reason}: {body}") from e


def download(url, api_key, path):
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {api_key}"})
    with urllib.request.urlopen(req, timeout=120) as res:
        path.write_bytes(res.read())


def generate(action, args, api_key):
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / f"{action}.mp4"
    if out.exists() and not args.overwrite:
        print(f"skip exists: {out}")
        return

    payload = {
        "model": args.model,
        "prompt": prompt_for(action),
        "duration": args.duration,
        "resolution": args.resolution,
        "aspect_ratio": "16:9",
        "generate_audio": False,
    }
    if args.dry_run:
        print(json.dumps({"action": action, "payload": payload}, ensure_ascii=False, indent=2))
        return

    job = request_json("POST", f"{BASE_URL}/videos", api_key, payload)
    print(f"{action}: submitted {job.get('id')} {job.get('status')}")

    polling_url = job.get("polling_url") or f"{BASE_URL}/videos/{job['id']}"
    while True:
        time.sleep(args.poll_seconds)
        status = request_json("GET", polling_url, api_key)
        print(f"{action}: {status.get('status')}")
        if status.get("status") == "completed":
            url = (status.get("unsigned_urls") or [f"{BASE_URL}/videos/{job['id']}/content?index=0"])[0]
            download(url, api_key, out)
            print(f"saved: {out}")
            return
        if status.get("status") == "failed":
            raise SystemExit(f"{action} failed: {status.get('error', status)}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="x-ai/grok-imagine-video")
    parser.add_argument("--duration", type=int, default=3)
    parser.add_argument("--resolution", default="720p")
    parser.add_argument("--poll-seconds", type=int, default=30)
    parser.add_argument("--start-at", default="Idle")
    parser.add_argument("--limit", type=int, default=1)
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    names = list(ACTIONS)
    if args.start_at not in ACTIONS:
        raise SystemExit(f"Unknown action: {args.start_at}")
    names = names[names.index(args.start_at):]
    if not args.all:
        names = names[: args.limit]

    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key and not args.dry_run:
        raise SystemExit("Set OPENROUTER_API_KEY first.")

    for action in names:
        generate(action, args, api_key)


if __name__ == "__main__":
    main()
