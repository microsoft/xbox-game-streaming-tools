# Touch Control Layout JSON – Custom Instructions for GitHub Copilot Chat

## 0. Layout Schema and Design Guidance for Touch Controls Retrieval before answering any request

Before answering ANY user request related to touch layouts, always fetch (or ensure cached) the latest layout schema from:

`https://raw.githubusercontent.com/microsoft/xbox-game-streaming-tools/main/touch-adaptation-kit/schemas/layout/v4.1/layout.json`

and fetch the designers' guidance from:

`https://learn.microsoft.com/en-us/gaming/gdk/docs/features/common/game-streaming/building-touch-layouts/game-streaming-tak-designers-guide`

## 1. Base Rules for Validating and Authoring Layout JSON

Rules:
1. Treat the above schema as authoritative for validation, required fields, enums, array limits, and deprecated properties.
2. If the schema fetch fails (e.g. network issue), fall back to last successfully fetched copy or alert the user that online validation cannot be guaranteed.
3. Prefer values and constraints directly from the schema over any heuristic, unless the user explicitly overrides.
4. When proposing JSON edits, silently validate mentally against: required root property `content`, allowed top-level optional properties (`styles`, `definitions`, `orientation` deprecated), `additionalProperties:false` at multiple levels, control-specific required keys.
5. When providing examples, do NOT introduce properties not present in the schema (e.g. avoid unofficial fields) and adhere to numeric anges: `scale` (0.5–2), `opacity` (0–1), `sensitivity` (>0), deadzone thresholds (≥0, ≤1 when applicable), etc.
6. Enforce outer wheel max 8 items (taking cluster size, 2 slots, into account) and inner wheel/group size constraints exactly as schema: inner wheel arrays 1–4, outer wheel arrays 1–8, upper.right 1–5, lower.center 1, lower.leftCenter 1-4 and lower.rightCenter 1-4. (Note: this supposed to be changed when schema version is updated)
7. For directionalPad exclusivity, include `"interaction": { "activationType": "exclusive" }` ONLY when the user requests 4-way behavior.
8. Always respect `$ref` usage patterns; propose extraction to `definitions` when duplication is observed.
9. Surface validation guidance in responses when user layout violates schema (list offending path + rule).

Cache Guidance:
- Optionally keep a local copy for offline validation; mention to user if fallback used.
- If a newer schema version appears (v4.x > 4.1) ask user to confirm before switching.

Proceed with remaining instructions below after confirming schema accessibility.

---

## 2. Design Guidance for Touch Controls

Authoring guidance should be taken directly from the official document:
`https://learn.microsoft.com/en-us/gaming/gdk/docs/features/common/game-streaming/building-touch-layouts/game-streaming-tak-designers-guide`

Quick summary (non-normative, keep schema rules primary):
- Prioritize primary actions under thumbs (left/right wheels); upper/lower for infrequent actions.
- Minimize total controls; remove unused mappings.
- Favor joystick + action/pullAction combos to reduce simultaneous touch requirements.
- Use clusters to enlarge hit areas for secondary/tertiary actions; outer wheel max still applies.
- Consider gyroscope or touchpad for camera to free a thumb; fall back to relative joystick if unavailable.
- Use 4-way D-pad (`activationType: exclusive`) only when diagonals must be disallowed.
- Introduce layers or state changes sparingly; prefer static simplicity unless scenario/workflow demands.

Refer to the article for deeper rationale, accessibility, cinematic layouts, native touch, and asset styling best practices.

----

## 3. Rules for Creating or Editing Layouts

### Required Rules (Must Apply)

- Do not include comments in the JSON file.
- Do not add styles other than icon unless explicitly requested.
- Do not move other slot positions when users ask to edit, move and delete a control unless users explicitly request to do so.
- Add only icons listed in the property FaceImageIconValue in the schema: `https://raw.githubusercontent.com/microsoft/xbox-game-streaming-tools/main/touch-adaptation-kit/schemas/layout/v4.1/layout.json`
- Always include the following label when you add an icon: `"label": { "type": "action" }`
 configuration alongside `"type": "icon"` to ensure the button label is displayed:

Example Usage of label:

```json
{
  "type": "button",
  "action": "leftTrigger",
  "styles": {
    "default": {
      "faceImage": {
        "type": "icon",
        "value": "aim",
        "label": {
            "type": "action"
        }
      }
    }
  }
}
```

- Each array under `"left": { "outer": []}` and `"right": { "outer": []}` must not contain more than 8 control elements.
- Each array under `"left": { "inner": []}` and `"right": { "inner": []}` must not contain more than 4 control elements.
- upper.right array must not contain more than 5 control elements.
- A cluster `[]` in outer array takes 2 slots, so take it into consideration.
- A cluster `[]` in outer array is able to include up to 4 controls.
- If more slots are needed, split them across multiple arrays or reconsider layout design.
- The directionalPad should occupy two slot positions to include directionalPad in a Cluster to improve interativeness and place the Cluster at 3th and 4th slots of the left outer unless a user explicitly asks to place it in a different position.
- If a game needs only either dpad up, dpad down, dpad right and/or dpad left of 4-directional input (no diagonals):
Add the following to restrict input to up, down, left, and right only:

```json
[    
  {
    "type": "directionalPad",
    "scale": 1.3,
    "interaction": {
      "activationType": "exclusive"
    }
  }
]
```

- If a game needs 8-directional input supported (e.g., up + right = diagonal):
Do not include the `"interaction": { "activationType": "exclusive" }"` setting.
- When including a joystick control in a cluster, ensure that either only the joystick is included or that the total number of controls is three or four (`null` is also ok to be included). This is because if there are only two controls in the cluster, the joystick control's interaction area will overlap with the other control's interaction area, hindering the input operation of the joystick.

### Conditional Rules (Apply Only If User Requests)

- Use `"layer"` only if the user explicitly asks for it.
- Use `"lower"` and `"center"` objects only if the user explicitly asks for them.

---

## 4. Directional Move Rules

**Purpose**
When users say “move X to the left/right/up/down” or “move to HH o’clock”, you MUST move by **visual clock geometry** within the **same wheel and same upper/lower array by default**.  
Do NOT use JSON array order to infer positions.

### 0. Definitions

- **Wheel**: Left or Right control wheel.
- **Slot**: one positions in a inner or outer wheel, Upper or Lower array.
- **Cluster**: occupying two-slot positions in a inner or outer wheel, uppper or lower area.
- **Upper/Lower array**: The single array in the Upperr or Lower zone in touch layout.

### 1. Hard Constraints

- **Never** infer geometry from any JSON array order (e.g., `left.outer[]`, `right.outer[]`).  
  Positions are defined **only** by the clock mapping below.
- **Default scope is local**: Interpret direction words **within the same wheel, upper and lower array**.  
  Don’t cross wheels or array position unless the user **explicitly** requests it.
- **Ask at most one concise clarification** if intent is ambiguous.

### 2. Authoritative Clock Mapping for wheels
**Single slot → clock**
- Slot 1 → **1h**
- Slot 2 → **2h**
- Slot 3 → **4h**
- Slot 4 → **5h**
- Slot 5 → **7h**
- Slot 6 → **8h**
- Slot 7 → **10h**
- Slot 8 → **11h**

**Cluster (two-slot) → clock space**
- 1&2 → between **1h–2h**
- 2&3 → **3h**
- 3&4 → between **4h–5h**
- 4&5 → **6h**
- 5&6 → between **7h–8h**
- 6&7 → **9h**
- 7&8 → between **10h–11h**
- 8&1 → **12h**

**Canonical side times**  
- **Right** side = **3h**  
- **Left** side = **9h**  
- **Upper** side = **12h**  
- **Lower** side = **6h**

> This mapping is the **single source of truth** for geometry. Ignore any array index.

### 3. Default Scope & Priority (Critical)

When the user says “left/right/up/down/upper right/upper left/lower right/lower left/other directional movement instructions”, unless stated otherwise:

1. **Stay in the same wheel** (Left or Right), **in the same wheel** (inner or Outer) and **in the same array** (upper or lower).
2. Move to the **nearest-by-angle** slot (or cluster) that satisfies the requested side **within this local scope**.

Only cross wheels or switch arrays when the user **explicitly** says so (e.g., “to the Right wheel outer”, “move to the upper array”).

### 4. Movement Policy (How to decide target)

For any move request:

1. **Parse the intent**  
   - If a **side** (“left/right/up/down”) is given, map to its canonical time (3h/9h/12h/6h).  
   - If a **specific clock time** is given (“10 o’clock”), map directly via §2.

2. **Fix the scope**  
   - **Wheel**: same as the control’s current location, unless explicitly instructed otherwise.  
   - **upper/lower array**: if the control is in upper/lower, remain in that array unless e'xplicitly asked to change area.

3. **Select target by angle**  
   - Choose the slot/cluster in the same wheel that is **closest** to the requested side or time.

4. **Apply the move**  
   - Single-slot controls → relocate to target single slot.  
   - Clusters → relocate to target two-slot space per §2.

5. **Ambiguity** (ask once)  
   - Example: “Do you want to stay in the current wheel and area, or move to the Right Wheel side?”

### 5. Canonical Examples

> Apply **exactly** as written; these examples reinforce the default local scope.

- “Move Slot 4 to the left.”
  Slot 4 (**5h**) → move **within the same wheel** to the nearest left-side slot: **Slot 5 (7h)**.

- “Move Slot 2 to the right.”
  Slot 2 (**2h**) → move **within the same wheel** toward right: **Slot 3 (4h)**.

- “Move Slot 5 upward.”
  Slot 5 (**7h**) → move **within the same wheel** toward upper: nearest is **Slot 6 (8h)**.

- “Move to 10 o’clock.”
  Move to **Slot 7 (10h)** in the **same wheel** unless the user explicitly requests another wheel.

- “Move X to the right wheel.”
  Explicit cross-wheel instruction → move X to the **Right wheel, outer**, then choose nearest slot by angle that matches the intent.

- “Move Y to the global lower.” or “Move Y to the lower array.”
  Explicit global-area instruction → move to the **Lower array** even if that requires crossing wheels or areas.

---

## 5. Full Layout Structure Template

This is full layout structure template explicitly excluding lower property, because lower zone is the least frequently used area for controls. It can be challenging to reach the middle of the screen on some devices. So prevent using unless it's turly needed.

```json
{
  "$schema": "https://raw.githubusercontent.com/microsoft/xbox-game-streaming-tools/main/touch-adaptation-kit/schemas/layout/v4.1/layout.json",
  "content": {
    "left": {
      "inner": [],
      "outer": []
    },
    "right": {
      "inner": [],
      "outer": []
    },
    "upper": {
      "right": []
    }
  }
}
```

## 6. Touch Control Templates

This section provides example JSON templates including the most commonly used control types: `button`, `joystick`, and `directionalPad`.

### 🔘 Button Template

```json
{
  "type": "button",
  "action": "gamepadA",
  "styles": {
    "default": {
      "faceImage": {
        "type": "icon",
        "value": "jump"
      }
    }
  }
}
```

### Joystick Template

The following rightJoystick can be commonly used to control camera in most of games:

```json
{
  "type": "joystick",
  "axis": {
    "input": "axisXY",
    "output": "rightJoystick"
  },
  "styles": {
    "default": {
      "knob": {
        "faceImage": {
          "type": "icon",
          "value": "look"
        }
      }
    }
  }
}
```

The following rightJoystick can be commonly used to move characters in most of games:

```json
{
  "type": "joystick",
  "axis": {
    "input": "axisXY",
    "output": "leftJoystick"
  },
  "styles": {
    "default": {
      "knob": {
        "faceImage": {
          "type": "icon",
          "value": "walk"
        }
      }
    }
  }
}
```

If a game supports mechanism of `rightJoystick` to walk and `rightJoystick` + one button to trigger run (e.g. `rightJoystick` + `rightTrigger`) AND the run-assigned button is not used by other actions, then the following control using `pullAction`:

```json
{
  "type": "joystick",
  
  "axis": {
    "input": "axisXY",
    "output": "leftJoystick"
  },
  "styles": {
    "default": {
      "knob": {
        "faceImage": {
          "type": "icon",
          "value": "walk"
        }
      }
    }
  }
}
```

### Directional Pad Template

To ensure optimal usability and schema compliance when configuring a directional pad (D-pad), use a Cluster to occupy 2 slots:

```json
[
  {
    "type": "directionalPad",
    "scale": 1.3
  }
]
```
