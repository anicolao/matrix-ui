// Matrix UI Frontend JavaScript
// This will handle the UI interactions and communicate with the Tauri backend

const { invoke } = window.__TAURI__.core;

// Application state
let appState = {
    currentRoom: null,
    rooms: [],
    messages: [],
    switcherVisible: false,
    globalSearch: false,
    capsLockState: {
        lastPress: 0,
        pressCount: 0
    }
};

// DOM elements
const elements = {
    carousel: document.getElementById('menu-bar-carousel'),
    chatWindow: document.getElementById('chat-window'),
    currentRoomName: document.getElementById('current-room-name'),
    roomStatus: document.getElementById('room-status'),
    messagesContainer: document.getElementById('messages'),
    messageInput: document.getElementById('message-input'),
    sendButton: document.getElementById('send-button'),
    chatSwitcher: document.getElementById('chat-switcher'),
    switcherSearch: document.getElementById('switcher-search'),
    scopeIndicator: document.getElementById('scope-indicator'),
    filteredResults: document.getElementById('filtered-results')
};

// Initialize the application
document.addEventListener('DOMContentLoaded', async () => {
    console.log('Matrix UI frontend loaded');
    
    // Test backend connection
    try {
        const response = await invoke('greet', { name: 'Matrix UI' });
        console.log('Backend response:', response);
    } catch (error) {
        console.error('Failed to connect to backend:', error);
    }
    
    // Set up event listeners
    setupEventListeners();
    
    // Initialize UI components
    initializeCarousel();
    initializeChatWindow();
    initializeChatSwitcher();
});

function setupEventListeners() {
    // Message input and sending
    elements.messageInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    
    elements.sendButton.addEventListener('click', sendMessage);
    
    // Avatar carousel clicks
    elements.carousel.addEventListener('click', (e) => {
        const avatarItem = e.target.closest('.avatar-item');
        if (avatarItem) {
            const roomId = avatarItem.dataset.roomId;
            selectRoom(roomId);
        }
    });
    
    // Chat switcher search
    elements.switcherSearch.addEventListener('input', (e) => {
        filterRooms(e.target.value);
    });
    
    // Chat switcher keyboard navigation
    elements.switcherSearch.addEventListener('keydown', (e) => {
        switch (e.key) {
            case 'Escape':
                hideChatSwitcher();
                break;
            case 'ArrowDown':
                e.preventDefault();
                navigateSwitcher(1);
                break;
            case 'ArrowUp':
                e.preventDefault();
                navigateSwitcher(-1);
                break;
            case 'Enter':
                e.preventDefault();
                selectFromSwitcher();
                break;
        }
    });
    
    // Global keyboard shortcuts (Caps Lock simulation with Ctrl+Shift+Space for demo)
    document.addEventListener('keydown', (e) => {
        if (e.ctrlKey && e.shiftKey && e.code === 'Space') {
            e.preventDefault();
            handleCapsLockPress();
        }
    });
    
    // Click outside to close switcher
    elements.chatSwitcher.addEventListener('click', (e) => {
        if (e.target === elements.chatSwitcher) {
            hideChatSwitcher();
        }
    });
}

function initializeCarousel() {
    // Simulate some demo rooms
    appState.rooms = [
        {
            id: 'room1',
            name: 'Work Team',
            avatar_url: 'https://via.placeholder.com/32/4aa3ff/ffffff?text=WT',
            last_message: 'Meeting at 3pm',
            unread_count: 0
        },
        {
            id: 'room2',
            name: 'Project Alpha',
            avatar_url: 'https://via.placeholder.com/32/ff4444/ffffff?text=PA',
            last_message: 'Code review completed',
            unread_count: 2
        },
        {
            id: 'room3',
            name: 'Design Discussion',
            avatar_url: 'https://via.placeholder.com/32/44ff44/ffffff?text=DD',
            last_message: 'New mockups uploaded',
            unread_count: 0
        }
    ];
    
    updateCarousel();
}

function updateCarousel() {
    const carousel = elements.carousel.querySelector('.avatar-carousel');
    carousel.innerHTML = '';
    
    appState.rooms.forEach(room => {
        const avatarItem = document.createElement('div');
        avatarItem.className = 'avatar-item';
        avatarItem.dataset.roomId = room.id;
        
        const img = document.createElement('img');
        img.src = room.avatar_url;
        img.alt = room.name;
        img.className = 'avatar-img';
        
        avatarItem.appendChild(img);
        
        if (room.unread_count > 0) {
            const badge = document.createElement('div');
            badge.className = 'notification-badge';
            badge.textContent = room.unread_count;
            avatarItem.appendChild(badge);
        }
        
        carousel.appendChild(avatarItem);
    });
}

function initializeChatWindow() {
    // Initially disabled until a room is selected
    elements.messageInput.disabled = true;
    elements.sendButton.disabled = true;
}

function initializeChatSwitcher() {
    // Hidden by default
    elements.chatSwitcher.style.display = 'none';
}

function selectRoom(roomId) {
    const room = appState.rooms.find(r => r.id === roomId);
    if (!room) return;
    
    appState.currentRoom = roomId;
    elements.currentRoomName.textContent = room.name;
    elements.roomStatus.textContent = `Connected • ${room.name}`;
    
    // Enable message input
    elements.messageInput.disabled = false;
    elements.sendButton.disabled = false;
    elements.messageInput.focus();
    
    // Clear unread count
    room.unread_count = 0;
    updateCarousel();
    
    // Load messages for this room (simulated)
    loadMessages(roomId);
}

function loadMessages(roomId) {
    // Simulate loading messages
    const demoMessages = [
        {
            sender: 'Alice',
            content: 'Hey everyone! How\'s the project going?',
            timestamp: new Date(Date.now() - 3600000)
        },
        {
            sender: 'Bob',
            content: 'Making good progress on the UI components',
            timestamp: new Date(Date.now() - 1800000)
        },
        {
            sender: 'You',
            content: 'Just finished the chat switcher implementation',
            timestamp: new Date(Date.now() - 900000)
        }
    ];
    
    elements.messagesContainer.innerHTML = '';
    
    demoMessages.forEach(message => {
        addMessageToUI(message);
    });
    
    scrollToBottom();
}

function addMessageToUI(message) {
    const messageElement = document.createElement('div');
    messageElement.className = 'message';
    
    messageElement.innerHTML = `
        <div class="message-sender">${message.sender}</div>
        <div class="message-content">${message.content}</div>
        <div class="message-time">${formatTime(message.timestamp)}</div>
    `;
    
    elements.messagesContainer.appendChild(messageElement);
}

function sendMessage() {
    const content = elements.messageInput.value.trim();
    if (!content || !appState.currentRoom) return;
    
    const message = {
        sender: 'You',
        content: content,
        timestamp: new Date()
    };
    
    addMessageToUI(message);
    elements.messageInput.value = '';
    scrollToBottom();
    
    // Here you would send the message to the backend
    console.log('Sending message:', message);
}

function handleCapsLockPress() {
    const now = Date.now();
    const timeSinceLastPress = now - appState.capsLockState.lastPress;
    
    if (timeSinceLastPress < 500) {
        // Double tap - global search
        showChatSwitcher(true);
    } else {
        // Single tap - local search
        showChatSwitcher(false);
    }
    
    appState.capsLockState.lastPress = now;
}

function showChatSwitcher(global = false) {
    appState.switcherVisible = true;
    appState.globalSearch = global;
    
    elements.chatSwitcher.style.display = 'flex';
    elements.scopeIndicator.textContent = global ? 'Global Scope' : 'Local Scope';
    elements.switcherSearch.value = '';
    elements.switcherSearch.focus();
    
    // Populate with all rooms for now
    filterRooms('');
}

function hideChatSwitcher() {
    appState.switcherVisible = false;
    elements.chatSwitcher.style.display = 'none';
    elements.switcherSearch.value = '';
    elements.filteredResults.innerHTML = '';
}

function filterRooms(query) {
    const filtered = appState.rooms.filter(room => 
        room.name.toLowerCase().includes(query.toLowerCase()) ||
        (room.last_message && room.last_message.toLowerCase().includes(query.toLowerCase()))
    );
    
    elements.filteredResults.innerHTML = '';
    
    filtered.forEach((room, index) => {
        const resultItem = document.createElement('div');
        resultItem.className = 'result-item';
        if (index === 0) resultItem.classList.add('selected');
        resultItem.dataset.roomId = room.id;
        
        resultItem.innerHTML = `
            <img src="${room.avatar_url}" alt="${room.name}" class="result-avatar">
            <div class="result-info">
                <div class="result-name">${room.name}</div>
                <div class="result-last-message">${room.last_message || 'No recent messages'}</div>
            </div>
        `;
        
        resultItem.addEventListener('click', () => {
            selectRoom(room.id);
            hideChatSwitcher();
        });
        
        elements.filteredResults.appendChild(resultItem);
    });
}

function navigateSwitcher(direction) {
    const items = elements.filteredResults.querySelectorAll('.result-item');
    const current = elements.filteredResults.querySelector('.result-item.selected');
    
    if (!items.length) return;
    
    let newIndex = 0;
    if (current) {
        const currentIndex = Array.from(items).indexOf(current);
        newIndex = (currentIndex + direction + items.length) % items.length;
        current.classList.remove('selected');
    }
    
    items[newIndex].classList.add('selected');
}

function selectFromSwitcher() {
    const selected = elements.filteredResults.querySelector('.result-item.selected');
    if (selected) {
        const roomId = selected.dataset.roomId;
        selectRoom(roomId);
        hideChatSwitcher();
    }
}

function animateNewMessage(roomId) {
    const avatarItem = elements.carousel.querySelector(`[data-room-id="${roomId}"]`);
    if (avatarItem) {
        avatarItem.classList.add('new-message');
        setTimeout(() => {
            avatarItem.classList.remove('new-message');
        }, 600);
    }
}

function scrollToBottom() {
    elements.messagesContainer.scrollTop = elements.messagesContainer.scrollHeight;
}

function formatTime(date) {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

// Simulate incoming messages for demo
setTimeout(() => {
    if (appState.rooms.length > 0) {
        const room = appState.rooms[1]; // Project Alpha
        room.unread_count += 1;
        updateCarousel();
        animateNewMessage(room.id);
        console.log('Simulated new message in', room.name);
    }
}, 5000);

// Export for potential use by other modules
window.MatrixUI = {
    selectRoom,
    showChatSwitcher,
    hideChatSwitcher,
    animateNewMessage
};