# Monti 🐻 — AI Voice Companion for Positive Child Development

> **"What if your child's favorite character could teach them healthy habits — not through fear, but through the power of questions?"**

Monti is a real-time AI voice companion that helps children aged 2–8 build positive habits through natural conversation. Instead of commands or threats, Monti uses guided questioning rooted in developmental psychology to help children discover the right actions on their own.

**Category:** Live Agents 🗣️ | **Hackathon:** Gemini Live Agent Challenge 2026

---

## The Problem

Every parent knows the struggle:

> *"Brush your teeth!" → "No!" → Frustration → Repeat.*

This is **Psychological Reactance** (Brehm, 1966) — a well-documented phenomenon where individuals resist perceived threats to their freedom of choice. When parents issue direct commands, children instinctively push back, not because they disagree, but because their autonomy feels threatened.

Existing solutions make this worse. Apps like "Oni Kara Denwa" (鬼から電話, 26M+ downloads in Japan) use **fear-based motivation** — a monster calls to scare children into compliance. Research consistently shows this approach causes harm:

- Fear-based discipline increases anxiety and behavioral problems (Gershoff, 2002)
- Children disciplined through threats show **1.5× higher risk** of mental health issues (Afifi et al., 2017)
- Compliance achieved through fear is **temporary** and does not build intrinsic motivation (Ryan & Deci, 2000)

## The Solution

Monti takes the opposite approach. Grounded in **50+ years of developmental psychology research**, Monti replaces commands with questions, helping children arrive at conclusions themselves.

| Traditional Approach | Monti's Approach |
|---------------------|-----------------|
| "Brush your teeth NOW!" | "What did you eat today? What happens to food on your teeth?" |
| Fear & threats | Guided discovery |
| Psychological Reactance (resistance) | Intrinsic motivation |
| No theoretical basis | Montessori + Socratic + SDT |
| Temporary compliance | Lasting behavior change |

### Example Conversation

```
🐻 Monti: "Heeey Yuu-chan! It's Monti! What yummy food did you eat today?"
👧 Child: "I had curry!"
🐻 Monti: "Ohhh! Curry is so yummy! Hey, what do you think happens
           to the curry bits stuck on your teeth?"
👧 Child: "Umm... they stay there?"
🐻 Monti: "Riiight! And what could you do to make them go away?"
👧 Child: "Brush my teeth!"
🐻 Monti: "Yaaay! That's a pinky promise with Monti! Go for it!
           I'm cheering for you! 🎉"
```

The child decides to brush their teeth **on their own** — no commands needed.

---

## Theoretical Foundation

Monti's conversation design is built on three pillars of developmental psychology:

### 1. Montessori Education

Maria Montessori's educational philosophy (1912) emphasizes **self-directed learning** where the adult serves as a guide, not an instructor. The child is empowered to discover through their own exploration.

- Longitudinal studies show Montessori-educated children demonstrate superior **cognitive flexibility** (d=0.61) and **mathematical problem-solving** (d=0.55) compared to traditional education (Lillard & Else-Quest, 2006)
- The approach fosters **executive function** and **self-regulation** — skills critical for habit formation (Diamond & Lee, 2011)

**How Monti applies this:** The AI character never gives direct answers. Instead, it asks questions that guide the child to discover the right action independently.

### 2. Socratic Method

The Socratic method uses structured questioning to help learners reach conclusions through their own reasoning, rather than being told what to think (Paul & Elder, 2007).

- Research with 5–6 year-olds demonstrates that Socratic dialogue produces **statistically significant improvements** in critical thinking skills (Reznitskaya et al., 2009)
- The method activates **metacognition** — children learn *how* to think, not just *what* to think

**How Monti applies this:** Each scenario follows a question chain (e.g., "What did you eat?" → "What happens to food on teeth?" → "What could you do?") that leads the child to the desired conclusion.

### 3. Self-Determination Theory (SDT)

Ryan & Deci's Self-Determination Theory (2000) identifies three basic psychological needs that drive intrinsic motivation:

| Need | Traditional Discipline | Monti's Approach |
|------|----------------------|-----------------|
| **Autonomy** | Denied ("Do as I say") | Supported ("What do you think?") |
| **Competence** | Undermined ("You can't even...") | Built ("You figured it out yourself!") |
| **Relatedness** | Conditional ("Good boy IF...") | Unconditional (parasocial bond with character) |

- Meta-analysis of 99 studies confirms that **autonomy-supportive** approaches produce greater internalization of behaviors compared to controlling approaches (Joussemet et al., 2008)
- SDT-based interventions show **sustained behavior change** even after the intervention ends, unlike reward/punishment systems (Deci, Koestner & Ryan, 1999)

### Supporting Research

| Theory | Application in Monti | Evidence |
|--------|---------------------|----------|
| **Parasocial Relationships** (Horton & Wohl, 1956) | Children form emotional bonds with media characters, increasing receptivity to messages | Bond strength correlates with learning outcomes (Calvert et al., 2014) |
| **Growth Mindset** (Dweck, 1998) | Monti praises effort ("You tried so hard!") not ability ("You're so smart!") | Process praise increases persistence by 30%+ vs. person praise (Mueller & Dweck, 1998) |
| **Personalization Effect** (Mayer, 2005) | Using the child's name and interests | Hearing one's own name activates unique brain regions; personalized content improves spelling accuracy by 20%+ (Cordova & Lepper, 1996) |
| **Age-Appropriate Pacing** | Speech speed and complexity adapt to child's age (3–4: very slow, 5–6: moderate, 7+: natural) | Slower speech rate improves comprehension in young children (Zangl & Mills, 2007) |

---

## Features

### Core Experience (Voice Conversation)
- **Real-time voice interaction** via Gemini Live API with natural turn-taking
- **Voice Activity Detection (VAD)** — children just talk, no buttons needed
- **Barge-in support** — children can interrupt naturally, just like a real conversation
- **Age-adaptive speech** — speed, vocabulary, and complexity adjust to the child's age
- **Goal detection** via function calling — conversation automatically concludes when the child commits to action
- **Character animation** — the character pulses and moves in sync with speech

### Personalization
- **Child profile** — name, age (2–8), and interests customize every conversation
- **6 AI characters** — each with unique personality, voice, and emoji (🐻🐰🦁🐱🐶🐼)
- **10 scenario templates** — brushing teeth, tidying up, bedtime, sharing, eating veggies, and more
- **Bilingual** — full Japanese and English support

### Conversation Design
- **Name calling** — the character addresses the child by name in every response
- **Promise closing** — goals are framed as a "promise with [character]" to reinforce commitment
- **Effort-based praise** — never "good boy/girl", always "you figured it out yourself!"
- **No fear, no threats** — strictly enforced via system prompt rules

### UX Polish
- **Incoming call simulation** — the experience starts with a ringing phone, making it feel magical for children
- **Celebration screen** — floating emojis, glow effects, and fanfare on goal completion (Cast Ending technique)
- **Smooth page transitions** — fade animations between all screens
- **Status indicators** — emoji-based visual feedback (🎤 listening, 🔊 talking, ✨ thinking)

---

## Architecture

```
┌─────────────────────────┐
│   Flutter App            │
│   (Android / iOS)        │
│                          │
│  ┌────────────────────┐  │
│  │ Audio Input (Mic)   │──┼──── 16kHz PCM mono ────┐
│  └────────────────────┘  │                          │
│  ┌────────────────────┐  │                          │  WebSocket
│  │ Audio Output (Spk)  │◄─┼── 24kHz PCM mono ──────┤  (Vertex AI)
│  └────────────────────┘  │                          │
│  ┌────────────────────┐  │                          │
│  │ Conversation State  │  │                          │
│  │ (Riverpod)          │  │                          │
│  └────────────────────┘  │                          │
└─────────────────────────┘                          │
                                                      ▼
                              ┌──────────────────────────────┐
                              │  Vertex AI (Google Cloud)      │
                              │                                │
                              │  Gemini Live API               │
                              │  gemini-live-2.5-flash-        │
                              │  native-audio (GA)             │
                              │                                │
                              │  • Native audio processing     │
                              │  • VAD & barge-in              │
                              │  • Function calling            │
                              │  • System prompt + tools       │
                              └──────────────────────────────┘
```

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Client** | Flutter (Dart) | Cross-platform mobile app |
| **AI Model** | Gemini Live 2.5 Flash Native Audio (GA) | Real-time voice conversation |
| **Cloud** | Vertex AI (Google Cloud) | Model hosting & API |
| **State** | Riverpod | Reactive state management |
| **Routing** | go_router | Declarative navigation |
| **Audio In** | record (Flutter package) | 16kHz PCM microphone capture |
| **Audio Out** | flutter_pcm_sound | 24kHz PCM streaming playback |
| **i18n** | Flutter l10n (ARB) | Japanese & English |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.27+
- Android device or emulator (API 21+)
- Google Cloud project with Vertex AI API enabled
- `gcloud` CLI authenticated

### Setup

```bash
# Clone the repository
git clone https://github.com/EijiAC24/monti-hackathon.git
cd monti-hackathon

# Install dependencies
flutter pub get

# Enable Vertex AI API (if not already)
gcloud services enable aiplatform.googleapis.com --project=YOUR_PROJECT_ID

# Build and run
TOKEN=$(gcloud auth print-access-token)
flutter run \
  --dart-define=ACCESS_TOKEN=$TOKEN \
  --dart-define=PROJECT_ID=YOUR_PROJECT_ID \
  --dart-define=LOCATION=us-central1
```

### Build APK

```bash
TOKEN=$(gcloud auth print-access-token)
flutter build apk --debug \
  --dart-define=ACCESS_TOKEN=$TOKEN \
  --dart-define=PROJECT_ID=YOUR_PROJECT_ID \
  --dart-define=LOCATION=us-central1
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── app.dart                       # MaterialApp configuration
│   └── router.dart                    # go_router with fade transitions
├── features/
│   ├── profile/                       # Child profile input (name, age, interests)
│   ├── scenario/                      # Scenario selection + timer
│   ├── waiting/                       # Countdown before call
│   ├── incoming_call/                 # Simulated incoming call UI
│   ├── conversation/                  # Core voice conversation screen
│   │   ├── conversation_screen.dart   # UI + celebration screen
│   │   └── conversation_provider.dart # Session management, audio pipeline
│   ├── home/                          # Child home screen
│   └── settings/                      # Language settings
├── models/
│   ├── child_profile.dart             # Child data model + character mapping
│   └── scenario.dart                  # Scenario templates
├── services/
│   ├── gemini_live_service.dart        # Vertex AI WebSocket connection
│   ├── audio_service.dart             # Mic recording + PCM playback
│   └── system_prompt.dart             # Age-adaptive prompt builder
├── shared/
│   ├── theme/app_theme.dart           # Design system (colors, shadows, radius)
│   └── widgets/monty_character.dart   # Animated character widget
└── l10n/                              # Japanese & English translations
```

---

## Key Technical Decisions

### Why Vertex AI (GA) over Google AI?

We initially used `gemini-2.5-flash-native-audio-preview` via Google AI, but **function calling was unreliable** — the model never called `end_conversation` to signal goal completion. Switching to Vertex AI's GA model (`gemini-live-2.5-flash-native-audio`) resolved this completely.

### Audio Pipeline Challenges

Building a real-time audio conversation for children required solving several non-trivial problems:

1. **Echo barge-in prevention** — The speaker's audio leaks into the microphone, causing false interruptions. We mute mic transmission while audio is playing, using a `_isSpeaking` flag gated by calculated playback drain time.

2. **Accurate drain timing** — Audio data arrives from the server in ~1 second but plays for 3–5 seconds. We track `_playbackStartTime` and `_bufferedBytes` to calculate *actual* remaining playback time: `remaining = totalAudioMs - elapsedMs`.

3. **Turn ID invalidation** — Stale unmute timers from previous turns could interfere with new responses. Each turn gets a unique `_turnId`, and timers check this before executing.

### Age-Adaptive System Prompts

The system prompt dynamically adjusts based on the child's age:

| Age | Speech Speed | Sentence Length | Style |
|-----|-------------|----------------|-------|
| 3–4 | Very slow, stretched vowels | 3–5 words | Baby-talk, onomatopoeia, big reactions |
| 5–6 | Gentle, moderate | 7 words | Simple why/how questions, concrete examples |
| 7+ | Natural | 10 words | Deeper questions, friend-like tone |

---

## References

1. Afifi, T. O., et al. (2017). Spanking and adult mental health impairment. *Child Abuse & Neglect*, 71, 24–31.
2. Brehm, J. W. (1966). *A Theory of Psychological Reactance*. Academic Press.
3. Calvert, S. L., et al. (2014). Electronic media and children's parasocial relationships. *Developmental Psychology*, 50(10), 2412.
4. Cordova, D. I., & Lepper, M. R. (1996). Intrinsic motivation and the process of learning. *Journal of Educational Psychology*, 88(4), 715.
5. Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A meta-analytic review of experiments examining the effects of extrinsic rewards on intrinsic motivation. *Psychological Bulletin*, 125(6), 627.
6. Diamond, A., & Lee, K. (2011). Interventions shown to aid executive function development in children 4 to 12 years old. *Science*, 333(6045), 959–964.
7. Dweck, C. S. (1998). The development of early self-conceptions. In *Handbook of Child Psychology*.
8. Gershoff, E. T. (2002). Corporal punishment by parents and associated child behaviors. *Psychological Bulletin*, 128(4), 539.
9. Horton, D., & Wohl, R. (1956). Mass communication and para-social interaction. *Psychiatry*, 19(3), 215–229.
10. Joussemet, M., Landry, R., & Koestner, R. (2008). A self-determination theory perspective on parenting. *Canadian Psychology*, 49(3), 194.
11. Lillard, A., & Else-Quest, N. (2006). Evaluating Montessori education. *Science*, 313(5795), 1893–1894.
12. Mayer, R. E. (2005). *The Cambridge Handbook of Multimedia Learning*. Cambridge University Press.
13. Montessori, M. (1912). *The Montessori Method*. Frederick A. Stokes Company.
14. Mueller, C. M., & Dweck, C. S. (1998). Praise for intelligence can undermine children's motivation and performance. *Journal of Personality and Social Psychology*, 75(1), 33.
15. Paul, R., & Elder, L. (2007). *Critical Thinking: The Art of Socratic Questioning*. Journal of Developmental Education, 31(1), 36.
16. Reznitskaya, A., et al. (2009). Collaborative reasoning: A dialogic approach to group discussions. *Cambridge Journal of Education*, 39(1), 29–48.
17. Ryan, R. M., & Deci, E. L. (2000). Self-determination theory and the facilitation of intrinsic motivation. *American Psychologist*, 55(1), 68.
18. Zangl, R., & Mills, D. L. (2007). Increased brain activity to infant-directed speech in 6- and 13-month-old infants. *Infancy*, 11(1), 31–62.

---

## License

This project was created for the Gemini Live Agent Challenge 2026.

## Team

Built by Eiji — [GitHub](https://github.com/EijiAC24)
