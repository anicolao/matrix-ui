// UI management module for handling the various UI components
// This module will coordinate the menu bar, chat window, and ephemeral switcher

use serde::{Deserialize, Serialize};
// use crate::matrix::Room;  // Commented out for initial scaffolding

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Room {
    pub id: String,
    pub name: String,
    pub avatar_url: Option<String>,
    pub last_message: Option<String>,
    pub unread_count: u32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Avatar {
    pub room_id: String,
    pub url: Option<String>,
    pub display_name: String,
    pub has_unread: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ChatCarousel {
    pub avatars: Vec<Avatar>,
    pub active_desktop: u32,
    pub filtered_by_desktop: bool,
}

impl ChatCarousel {
    pub fn new() -> Self {
        Self {
            avatars: Vec::new(),
            active_desktop: 0,
            filtered_by_desktop: false,
        }
    }

    pub fn update_avatars(&mut self, rooms: &[Room]) {
        self.avatars = rooms
            .iter()
            .map(|room| Avatar {
                room_id: room.id.clone(),
                url: room.avatar_url.clone(),
                display_name: room.name.clone(),
                has_unread: room.unread_count > 0,
            })
            .collect();
    }

    pub fn filter_by_desktop(&mut self, desktop_id: u32, room_ids: &[String]) {
        if self.filtered_by_desktop {
            self.avatars.retain(|avatar| room_ids.contains(&avatar.room_id));
        }
        self.active_desktop = desktop_id;
    }

    pub fn animate_new_message(&mut self, room_id: &str) {
        // Find the avatar and move it to the front
        if let Some(index) = self.avatars.iter().position(|avatar| avatar.room_id == room_id) {
            let mut avatar = self.avatars.remove(index);
            avatar.has_unread = true;
            self.avatars.insert(0, avatar);
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ChatSwitcher {
    pub visible: bool,
    pub search_query: String,
    pub filtered_rooms: Vec<Room>,
    pub selected_index: usize,
    pub global_search: bool,
}

impl ChatSwitcher {
    pub fn new() -> Self {
        Self {
            visible: false,
            search_query: String::new(),
            filtered_rooms: Vec::new(),
            selected_index: 0,
            global_search: false,
        }
    }

    pub fn show(&mut self, global: bool) {
        self.visible = true;
        self.global_search = global;
        self.search_query.clear();
        self.selected_index = 0;
    }

    pub fn hide(&mut self) {
        self.visible = false;
        self.search_query.clear();
        self.filtered_rooms.clear();
        self.selected_index = 0;
    }

    pub fn update_search(&mut self, query: String, rooms: &[Room]) {
        self.search_query = query;
        self.filtered_rooms = rooms
            .iter()
            .filter(|room| {
                room.name.to_lowercase().contains(&self.search_query.to_lowercase())
                    || room.last_message
                        .as_ref()
                        .map(|msg| msg.to_lowercase().contains(&self.search_query.to_lowercase()))
                        .unwrap_or(false)
            })
            .cloned()
            .collect();
        
        // Reset selection to first item
        self.selected_index = 0;
    }

    pub fn select_next(&mut self) {
        if !self.filtered_rooms.is_empty() {
            self.selected_index = (self.selected_index + 1) % self.filtered_rooms.len();
        }
    }

    pub fn select_previous(&mut self) {
        if !self.filtered_rooms.is_empty() {
            self.selected_index = if self.selected_index == 0 {
                self.filtered_rooms.len() - 1
            } else {
                self.selected_index - 1
            };
        }
    }

    pub fn get_selected_room(&self) -> Option<&Room> {
        self.filtered_rooms.get(self.selected_index)
    }
}

#[derive(Debug)]
pub struct UIState {
    pub carousel: ChatCarousel,
    pub switcher: ChatSwitcher,
    pub current_room: Option<String>,
    pub window_focused: bool,
}

impl UIState {
    pub fn new() -> Self {
        Self {
            carousel: ChatCarousel::new(),
            switcher: ChatSwitcher::new(),
            current_room: None,
            window_focused: false,
        }
    }

    pub fn update_current_room(&mut self, room_id: Option<String>) {
        self.current_room = room_id;
    }

    pub fn set_window_focus(&mut self, focused: bool) {
        self.window_focused = focused;
    }
}