## Inspiration

It started with my niece. She absolutely refused to brush her teeth — no amount of asking, pleading, or explaining worked. But one day, while playing pretend phone calls with her stuffed bear, she suddenly announced: *"Bear says I should brush my teeth! OK!"* and ran to the bathroom.

That moment stuck with me. **A third party — even an imaginary one — could reach her in a way her parents couldn't.** This isn't a coincidence. Research on **Parasocial Relationships** (Horton & Wohl, 1956) shows that children form genuine emotional bonds with characters, making them more receptive to guidance. And **Self-Determination Theory** (Ryan & Deci, 2000) explains why: when autonomy is preserved — when the child *chooses* to act rather than being *told* — motivation becomes intrinsic and lasting.

I thought: what if we could combine the power of a beloved character with the intelligence of a real-time AI that listens, adapts, and guides through questions? That's how Monti was born.

## What It Does

Monti is a **real-time AI voice companion** for children aged 2–8, built for the **Live Agents** category. A friendly AI character literally *calls* the child's phone, creating a magical moment — "Monty is calling you!"

The conversation is fully voice-driven with **no buttons needed**. The child just talks naturally, and Monti:
- **Listens** with Voice Activity Detection — no tap-to-talk
- **Responds** with natural, age-adaptive speech in real time
- **Handles interruptions** gracefully via barge-in support
- **Guides** through Socratic questioning — never commands, always asks
- **Celebrates** when the child decides to act — with fanfare and a "pinky promise"

Example flow for a tooth-brushing scenario:
> 🐻 "Heeey Yuu-chan! What yummy food did you eat today?"
> 👧 "Curry!"
> 🐻 "Ohhh! What do you think happens to curry bits on your teeth?"
> 👧 "They stay there?"
> 🐻 "Right! What could you do about that?"
> 👧 "Brush my teeth!"
> 🐻 "Yaaay! It's a pinky promise with Monty! Go brush! 🎉"

The child decided **on their own**. No commands. No fear. Just guided discovery.

## The Science Behind It

This isn't just a chatbot with a cute voice. Every conversation design choice is backed by developmental psychology:

| Principle | Application in Monti | Evidence |
|-----------|---------------------|----------|
| **Montessori Education** | Child discovers, AI guides | Cognitive flexibility d=0.61 (Lillard & Else-Quest, 2006) |
| **Socratic Method** | Questions, not answers | Critical thinking gains in 5-6 year-olds (Reznitskaya et al., 2009) |
| **Self-Determination Theory** | Autonomy over control | Lasting behavior change vs. temporary compliance (Ryan & Deci, 2000) |
| **Growth Mindset** | Praise effort, not ability | Process praise increases persistence 30%+ (Mueller & Dweck, 1998) |
| **Personalization** | Always calls child by name | Name recognition activates unique brain regions (Mayer, 2005) |
| **Age-Adaptive Pacing** | Slower speech for younger kids | Slower rate improves comprehension in young children (Zangl & Mills, 2007) |

## How We Built It — 5 Days, Start to Finish

### Day 1-2: Foundation & Gemini Live API
Built the Flutter app foundation and connected to Gemini's Live API via WebSocket. Got real-time audio streaming working — 16kHz PCM in, 24kHz PCM out. The first time Monty spoke back was magical.

### Day 3: The Audio Pipeline Battle
The hardest part of the entire project. Three major issues:
1. **Echo barge-in** — The speaker's audio leaked into the microphone, causing Gemini to think the child was interrupting. Solved with `_isSpeaking` flag + calculated drain timing based on buffered PCM bytes minus elapsed playback time
2. **Function calling failure** — The Google AI preview model never called `end_conversation`. Switched to **Vertex AI GA model** (`gemini-live-2.5-flash-native-audio`) which resolved it immediately
3. **Premature goal detection** — The model sometimes called `end_conversation` on the first turn. Added both prompt-level and code-level guards (minimum 2 completed turns)

### Day 4: Cloud Run & Character Generation
- Built a **Cloud Run** token server so the app never needs hardcoded credentials
- Added **AI character generation** using **Gemini 3.1 Flash Image Preview** — parents describe any character ("a friendly purple dinosaur") and get a flat emoji-style avatar instantly
- This is what makes Monti truly AI-native: **both the conversation AND the characters are AI-generated**

### Day 5: Polish & Submission
- Age-adaptive system prompts (3-4: baby-talk with stretched vowels, 5-6: moderate, 7+: natural)
- detail.design UI techniques: page transitions, celebration screen with floating emojis, talking pulse animation
- Character asset images, incoming call simulation, bilingual support (EN/JP)

## Google Cloud Architecture

```
Flutter App ──WebSocket──► Vertex AI (Gemini Live API)
     │                      • Native audio processing
     │                      • VAD & barge-in
     │                      • Function calling
     │
     ├──── HTTP ──────────► Cloud Run
     │                      • Token server (service account auth)
     │                      • Character image generation
     │                      • Gemini 3.1 Flash proxy
```

**Google Cloud services used:**
- **Vertex AI** — Gemini Live 2.5 Flash Native Audio (GA) for real-time voice conversation
- **Cloud Run** — Backend token server + AI character generation proxy
- **Gemini 3.1 Flash Image Preview** — On-demand character avatar generation

## What We Learned

- **Vertex AI GA vs Google AI Preview** — Function calling only worked reliably on the GA model. This single switch fixed our biggest blocker
- **Audio timing is everything** — The gap between "server finished sending data" and "speaker finished playing" was the root cause of 80% of our UX bugs
- **Designing for children ≠ designing for adults** — Slower pace, shorter sentences, emotional warmth, and name-calling matter far more than response accuracy
- **AI-generated characters change the product** — Moving from template selection to "describe your character" transformed Monti from an app into a platform

## What's Next

- **Parent dashboard** with AI-generated conversation insights and progress tracking
- **Community scenario marketplace** — parents share custom missions
- **Speech development analytics** based on conversation patterns
- **Multi-language expansion** — currently EN/JP, targeting 24 languages supported by Gemini
- **Rive character animations** — replacing static images with dynamic expressions
