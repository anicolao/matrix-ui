### Matrix UI: A Context-Aware Chat Client for Modern Workflows

This document outlines a design proposal for a new Matrix chat client that is optimized for multi-project, multi-desktop workflows. The core principle of this design is to create a UI that is both highly aware of a user's real-time environment and non-intrusive, balancing the need for constant updates with the necessity of deep focus.

#### 1. The Dynamic Menu Bar Presence

The chat client will feature a small, persistent presence in the operating system's menu bar (e.g., at the top of a macOS screen). This is the user's ambient notification hub.

* **Avatar Carousel:** The widget will display a small, horizontal carousel of avatars or icons representing the most recently active chats.
* **Animated Notifications:** When a new message arrives, the corresponding chat's avatar will animate smoothly into the front of the carousel, displacing the oldest icon in a visually pleasing manner.
* **Contextual Audio Cues:** The system will support per-chat audio notifications. These can be configured to play only when the user is on a virtual desktop that matches the chat's context (e.g., a "Work" chat sound only plays on the "Work" desktop).
* **Contextual Filtering:** For maximum focus, users can choose to have the menu bar carousel itself filtered to show only the avatars from conversations relevant to their current virtual desktop.

#### 2. The Context-Aware Chat Window

The main chat interface is a single, tall and narrow window that the user can place and manage via their operating system's window manager.

* **Topic-Specific Content:** The chat window will only display conversations that are relevant to its current virtual desktop. This is a critical feature to prevent off-topic messages from appearing and to avoid potential embarrassment during screen-sharing.
* **Unambiguous Destination:** The UI is a single conversation pane with a clear, always-visible input box. This removes any confusion about where a message is being sent.

#### 3. The Ephemeral Chat Switcher

This is the central navigation mechanism, designed for speed and power-user efficiency.

* **Local Scope:** A single tap of the **Caps Lock** key triggers an ephemeral, floating UI. This UI appears over the current virtual desktop, presenting a filtered carousel of avatars and a search bar containing only the conversations relevant to the current desktop. Typing in the search bar dynamically filters the results.
* **Global Scope:** A second, consecutive tap of **Caps Lock** expands the search. The system will now look for the typed phrase across all chats on all virtual desktops.
* **Intelligent Desktop Switching:** When a user selects a chat from a different desktop and presses **Enter**, the system will automatically perform a seamless action:
    1.  Switch the virtual desktop to the correct one.
    2.  Bring the chat window on that desktop into focus.
    3.  Load the selected conversation into the window.

This design creates a workflow that is fluid, intuitive, and tailored to the modern professional's need for both constant connection and periods of deep, uninterrupted focus.
