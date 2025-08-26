# Matrix UI Implementation Sketch

This document outlines the recommended technologies, frameworks, and implementation approaches for building the Matrix UI chat client as described in the README.md. The implementation targets macOS and Linux platforms with cross-platform compatibility as a primary goal.

## Executive Summary

**Recommended Primary Stack:**
- **Language:** Rust with Tauri framework
- **Alternative:** TypeScript/JavaScript with Electron + Native modules
- **UI Framework:** Web technologies (HTML/CSS/JS) with native bridges
- **Matrix SDK:** matrix-rust-sdk or matrix-js-sdk

## Core Technical Requirements Analysis

Based on the design specification, the implementation must handle:

1. **System Integration:**
   - Menu bar/system tray presence
   - Global keyboard shortcuts (Caps Lock remapping)
   - Virtual desktop detection and switching
   - Window management and focus control

2. **Matrix Protocol:**
   - Real-time message synchronization
   - Multi-room management
   - End-to-end encryption support
   - Media handling (avatars, files)

3. **UI/UX Features:**
   - Smooth animations and transitions
   - Ephemeral overlay windows
   - Context-aware filtering
   - Audio notification system

## Recommended Implementation Approaches

### Option 1: Rust + Tauri (Recommended)

**Why Rust + Tauri:**
- Excellent cross-platform support for macOS and Linux
- Native performance with small memory footprint
- Strong Matrix ecosystem with `matrix-rust-sdk`
- Built-in system tray and global shortcuts support
- Web frontend allows for complex UI animations
- Excellent security model
- Native desktop integration capabilities

**Key Libraries:**
```toml
[dependencies]
tauri = { version = "1.5", features = ["system-tray", "global-shortcut", "window-all"] }
matrix-sdk = "0.7"
tokio = "1.0"
serde = { version = "1.0", features = ["derive"] }
tauri-plugin-window-state = "0.1"
rdev = "0.4" # For advanced keyboard handling
enigo = "0.0.14" # For desktop automation
```

**Platform-Specific Crates:**
- **macOS:** `core-graphics`, `cocoa`, `objc` for desktop switching
- **Linux:** `x11`, `xcb`, `libwnck` for window management

**Architecture:**
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Frontend  │◄───│  Tauri Bridge    │◄───│  Rust Backend   │
│  (HTML/CSS/JS)  │    │  (IPC Commands)  │    │ (Matrix Client) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        │                        │                        │
        ▼                        ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UI Animations │    │ System Tray      │    │ Virtual Desktop │
│   Chat Interface│    │ Global Shortcuts │    │ Management      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Option 2: TypeScript + Electron + Native Modules

**Why Electron + Native:**
- Mature ecosystem with extensive documentation
- Rich UI capabilities with web technologies
- Strong Matrix support via `matrix-js-sdk`
- Native modules for system integration

**Key Dependencies:**
```json
{
  "dependencies": {
    "electron": "^27.0.0",
    "matrix-js-sdk": "^27.0.0",
    "@electron/remote": "^2.0.0",
    "electron-store": "^8.0.0",
    "node-global-key-listener": "^0.1.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "electron-builder": "^24.0.0",
    "typescript": "^5.0.0"
  }
}
```

**Native Modules:**
- **macOS:** `macos-desktop-switcher` (custom native module)
- **Linux:** `linux-desktop-manager` (X11/Wayland integration)

### Option 3: Go + Fyne/Wails (Alternative)

**Considerations:**
- Good cross-platform support
- Smaller ecosystem for Matrix clients
- Less mature UI animation capabilities
- Simpler deployment model

## Platform-Specific Implementation Details

### macOS Implementation

**System Integration:**
```rust
// Using Tauri + macOS-specific crates
use cocoa::appkit::{NSStatusBar, NSStatusItem};
use core_graphics::display::CGGetActiveDisplayList;

// Menu bar integration
let status_bar = NSStatusBar::systemStatusBar();
let status_item = status_bar.statusItemWithLength_(-1.0);

// Desktop switching via Mission Control
use core_graphics::window::{kCGWindowListOptionAll, CGWindowListCopyWindowInfo};
```

**Key APIs:**
- NSStatusBar for menu bar presence
- NSWorkspace for virtual desktop management
- Carbon Events API for global shortcuts
- AVFoundation for audio notifications

### Linux Implementation

**System Integration:**
```rust
// X11/Wayland integration
use x11::xlib::{XOpenDisplay, XCloseDisplay, XGetWindowProperty};
use libwnck::Window;

// System tray using freedesktop specification
let tray = SystemTray::new()
    .with_icon(icon_data)
    .with_tooltip("Matrix UI");

// Desktop switching via EWMH
use x11::xlib::{_NET_CURRENT_DESKTOP, _NET_NUMBER_OF_DESKTOPS};
```

**Key Technologies:**
- **X11/Wayland:** Window management and desktop switching
- **DBus:** System notifications and desktop integration
- **PulseAudio/ALSA:** Audio notification system
- **GTK/Qt system tray:** For system tray integration

## Matrix Protocol Integration

### Recommended SDK: matrix-rust-sdk

```rust
use matrix_sdk::{
    Client, config::SyncSettings, ruma::events::room::message::SyncRoomMessageEvent,
};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new(homeserver_url).await?;
    client.login_username(&username, &password).initial_device_display_name(&device_name).await?;
    
    // Set up sync with custom filter for efficiency
    let sync_settings = SyncSettings::default().token(client.sync_token().await);
    
    // Room event handling
    client.register_event_handler(on_room_message).await;
    client.sync(sync_settings).await?;
    
    Ok(())
}

async fn on_room_message(event: SyncRoomMessageEvent, room: Room) {
    // Handle incoming messages for UI updates
    // Trigger avatar carousel animations
    // Apply contextual filtering based on current desktop
}
```

### Key Matrix Features Implementation:

1. **Room Management:**
   - Maintain room-to-desktop mappings
   - Implement efficient sync filtering
   - Handle room state updates

2. **Message Processing:**
   - Real-time message rendering
   - Notification routing based on context
   - Message search across desktops

3. **User Presence:**
   - Avatar updates and status changes
   - Typing indicators
   - Read receipts

## UI Framework and Animation System

### Frontend Architecture (Web-based)

```typescript
// Vue.js/React component structure
interface ChatCarousel {
  avatars: Avatar[];
  activeDesktop: string;
  animateNewMessage(roomId: string): void;
  filterByDesktop(desktop: string): Avatar[];
}

// CSS animations for smooth transitions
.avatar-carousel {
  display: flex;
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.avatar-item {
  transition: all 0.2s ease-in-out;
  transform-origin: center;
}

.avatar-item.new-message {
  animation: pulse-notification 0.6s ease-in-out;
}
```

### Animation System:
- CSS3 transitions for avatar carousel
- JavaScript animation libraries (Framer Motion, Lottie)
- Hardware-accelerated transforms
- Smooth desktop transition effects

## Virtual Desktop Management

### Desktop Detection and Switching

```rust
// Cross-platform desktop management trait
trait DesktopManager {
    fn get_current_desktop(&self) -> Result<u32, Error>;
    fn get_desktop_count(&self) -> Result<u32, Error>;
    fn switch_to_desktop(&self, desktop: u32) -> Result<(), Error>;
    fn get_desktop_name(&self, desktop: u32) -> Result<String, Error>;
}

// macOS implementation
struct MacOSDesktopManager;
impl DesktopManager for MacOSDesktopManager {
    fn switch_to_desktop(&self, desktop: u32) -> Result<(), Error> {
        // Use CGSGetNumberOfSpaces and CGSSetWorkspace
        unsafe {
            CGSSetWorkspace(CGSMainConnectionID(), desktop as i32);
        }
        Ok(())
    }
}

// Linux implementation  
struct LinuxDesktopManager;
impl DesktopManager for LinuxDesktopManager {
    fn switch_to_desktop(&self, desktop: u32) -> Result<(), Error> {
        // Use EWMH _NET_CURRENT_DESKTOP
        let display = XOpenDisplay(std::ptr::null());
        // Set _NET_CURRENT_DESKTOP property
        Ok(())
    }
}
```

### Context Mapping:
```rust
#[derive(Serialize, Deserialize)]
struct ContextMapping {
    desktop_id: u32,
    room_ids: Vec<String>,
    notification_settings: NotificationSettings,
}

struct ContextManager {
    mappings: HashMap<u32, ContextMapping>,
    current_desktop: u32,
}
```

## Global Keyboard Shortcuts

### Caps Lock Remapping Strategy:

```rust
use rdev::{listen, Event, EventType, Key};

fn setup_global_shortcuts() -> Result<(), Error> {
    let mut caps_lock_state = CapsLockState::new();
    
    listen(move |event: Event| {
        match event.event_type {
            EventType::KeyPress(Key::CapsLock) => {
                caps_lock_state.handle_press();
                if caps_lock_state.should_trigger_local_search() {
                    show_local_chat_switcher();
                } else if caps_lock_state.should_trigger_global_search() {
                    show_global_chat_switcher();
                }
            }
            _ => {}
        }
    })?;
    
    Ok(())
}

struct CapsLockState {
    last_press: Instant,
    press_count: u8,
}
```

## Build and Deployment Strategy

### Tauri Build Configuration:

```toml
# tauri.conf.json equivalent in TOML
[build]
dist_dir = "../dist"
dev_path = "http://localhost:3000"

[package]
product_name = "Matrix UI"
version = "0.1.0"

[tauri.bundle]
identifier = "com.matrix-ui.app"
icon = ["icons/32x32.png", "icons/128x128.png", "icons/icon.ico"]

[tauri.bundle.macOS]
license = "LICENSE"
frameworks = []
minimum_system_version = "10.15"

[tauri.bundle.linux]
categories = ["Network", "Chat"]
```

### Development Workflow:

1. **Frontend Development:**
   ```bash
   npm run dev          # Start web dev server
   cargo tauri dev      # Start Tauri development mode
   ```

2. **Platform Testing:**
   ```bash
   # macOS testing
   cargo tauri build --target x86_64-apple-darwin
   cargo tauri build --target aarch64-apple-darwin
   
   # Linux testing
   cargo tauri build --target x86_64-unknown-linux-gnu
   ```

3. **Distribution:**
   - **macOS:** Code signing and notarization required
   - **Linux:** AppImage, .deb, and .rpm packages
   - **Auto-updater:** Tauri's built-in update mechanism

## Security Considerations

### Matrix E2E Encryption:
- Leverage matrix-rust-sdk's built-in Olm/Megolm implementation
- Secure key storage using platform keychain services
- Session verification and cross-signing support

### System Access Permissions:
- Request minimal necessary permissions
- Accessibility permissions for global shortcuts (macOS)
- X11 permissions for desktop switching (Linux)

### Data Storage:
- Encrypted local storage for Matrix state
- Secure credential storage
- Privacy-conscious logging

## Testing Strategy

### Unit Testing:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_desktop_context_filtering() {
        let context_manager = ContextManager::new();
        let rooms = context_manager.get_rooms_for_desktop(1);
        assert_eq!(rooms.len(), 3);
    }

    #[test]
    fn test_caps_lock_timing() {
        let mut state = CapsLockState::new();
        state.handle_press();
        assert!(!state.should_trigger_global_search());
        
        thread::sleep(Duration::from_millis(100));
        state.handle_press();
        assert!(state.should_trigger_global_search());
    }
}
```

### Integration Testing:
- Matrix homeserver integration tests
- Platform-specific desktop switching tests
- UI automation tests for critical workflows

### Performance Testing:
- Memory usage profiling
- Animation performance benchmarks
- Large room handling tests

## Development Timeline Estimate

### Phase 1: Core Infrastructure (4-6 weeks)
- [ ] Basic Tauri application setup
- [ ] Matrix SDK integration
- [ ] Cross-platform desktop management
- [ ] Basic system tray implementation

### Phase 2: UI Development (4-5 weeks)
- [ ] Chat window interface
- [ ] Avatar carousel component
- [ ] Animation system
- [ ] Ephemeral chat switcher

### Phase 3: System Integration (3-4 weeks)
- [ ] Global keyboard shortcuts
- [ ] Context-aware filtering
- [ ] Audio notification system
- [ ] Desktop switching automation

### Phase 4: Polish and Testing (2-3 weeks)
- [ ] Performance optimization
- [ ] Platform-specific refinements
- [ ] Comprehensive testing
- [ ] Documentation and distribution

**Total Estimated Timeline: 13-18 weeks**

## Conclusion

The Rust + Tauri approach offers the best balance of performance, cross-platform support, and development efficiency for this project. The combination of native system integration capabilities with modern web UI technologies provides the flexibility needed to implement the sophisticated context-aware features described in the design specification.

The modular architecture allows for incremental development and testing, while the strong typing and safety guarantees of Rust help ensure robust system-level integration across both macOS and Linux platforms.