// Phone UI Controller
class RMFPhoneUI {
    constructor() {
        this.currentScreen = 'setup';
        this.isSetupComplete = false;
        this.phoneNumber = '';
        this.currentChat = null;
        this.controlCenterOpen = false;
        this.notificationsOpen = false;
        
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.updateTime();
        this.startTimeUpdate();
        this.checkSetupStatus();
    }

    setupEventListeners() {
        // Setup screen
        document.getElementById('getStartedBtn').addEventListener('click', () => {
            this.completeSetup();
        });

        // App icons - home screen
        document.querySelectorAll('.app-icon, .dock-app').forEach(icon => {
            icon.addEventListener('click', () => {
                const app = icon.dataset.app;
                if (app) {
                    this.openApp(app);
                }
            });
        });

        // Home indicators
        document.querySelectorAll('.home-indicator').forEach(indicator => {
            indicator.addEventListener('click', () => {
                this.goToHome();
            });
        });

        // Settings icon
        document.getElementById('settingsIcon').addEventListener('click', () => {
            this.openApp('settings');
        });

        // Phone app tabs
        document.querySelectorAll('.phone-tabs .tab').forEach(tab => {
            tab.addEventListener('click', () => {
                this.switchPhoneTab(tab.dataset.tab);
            });
        });

        // Dialpad buttons
        document.querySelectorAll('.dialpad-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                this.addToPhoneNumber(btn.dataset.number);
            });
        });

        // Call button
        document.getElementById('callBtn').addEventListener('click', () => {
            this.makeCall();
        });

        // Contact items
        document.querySelectorAll('.contact-item').forEach(contact => {
            contact.addEventListener('click', () => {
                const number = contact.querySelector('.contact-number').textContent;
                this.callContact(number);
            });
        });

        // Message items
        document.querySelectorAll('.message-item').forEach(message => {
            message.addEventListener('click', () => {
                const chatId = message.dataset.chat;
                this.openChat(chatId);
            });
        });

        // Chat functionality
        document.getElementById('backToMessages').addEventListener('click', () => {
            this.goToApp('messages');
        });

        document.getElementById('sendMessage').addEventListener('click', () => {
            this.sendMessage();
        });

        document.getElementById('messageInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.sendMessage();
            }
        });

        // Google search
        document.getElementById('searchBtn').addEventListener('click', () => {
            this.performSearch();
        });

        document.getElementById('searchInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.performSearch();
            }
        });

        // Camera controls
        document.querySelectorAll('.camera-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                this.switchCameraMode(btn.textContent.toLowerCase());
            });
        });

        document.querySelector('.capture-btn').addEventListener('click', () => {
            this.capturePhoto();
        });

        // Settings back button
        document.getElementById('backFromSettings').addEventListener('click', () => {
            this.goToHome();
        });

        // Control center
        this.setupControlCenter();

        // Notifications
        this.setupNotifications();

        // Phone number input
        document.getElementById('phoneNumber').addEventListener('input', (e) => {
            this.phoneNumber = e.target.value;
        });

        // Status bar interactions
        document.querySelector('.status-bar').addEventListener('click', (e) => {
            if (e.target.closest('.status-left')) {
                this.toggleNotifications();
            } else if (e.target.closest('.status-right')) {
                this.toggleControlCenter();
            }
        });

        // ESC key to close phone
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.closePhone();
            }
        });

        // Touch/swipe gestures (simplified)
        this.setupGestures();
    }

    setupGestures() {
        let startY = 0;
        let startX = 0;

        document.addEventListener('touchstart', (e) => {
            startY = e.touches[0].clientY;
            startX = e.touches[0].clientX;
        });

        document.addEventListener('touchend', (e) => {
            const endY = e.changedTouches[0].clientY;
            const endX = e.changedTouches[0].clientX;
            const diffY = startY - endY;
            const diffX = startX - endX;

            // Swipe up for control center
            if (diffY > 50 && Math.abs(diffX) < 100 && startY > window.innerHeight - 100) {
                this.toggleControlCenter();
            }

            // Swipe down for notifications
            if (diffY < -50 && Math.abs(diffX) < 100 && startY < 100) {
                this.toggleNotifications();
            }
        });
    }

    setupControlCenter() {
        document.querySelectorAll('.control-item').forEach(item => {
            item.addEventListener('click', () => {
                item.classList.toggle('active');
                const control = item.className.split(' ')[1];
                this.toggleControl(control);
            });
        });

        document.querySelector('.brightness-slider').addEventListener('input', (e) => {
            this.setBrightness(e.target.value);
        });
    }

    setupNotifications() {
        // Add notification interactions if needed
    }

    checkSetupStatus() {
        // Check if setup was completed before
        const setupComplete = localStorage.getItem('rmf-phone-setup');
        if (setupComplete === 'true') {
            this.isSetupComplete = true;
            this.goToHome();
        }
    }

    completeSetup() {
        this.isSetupComplete = true;
        localStorage.setItem('rmf-phone-setup', 'true');
        this.animateScreenTransition('setupScreen', 'homeScreen');
        this.currentScreen = 'home';
        
        // Send setup complete event to FiveM
        this.sendNUICallback('rmf-phone:setupComplete', {});
    }

    goToHome() {
        this.closeControlCenter();
        this.closeNotifications();
        
        if (this.currentScreen === 'setup') {
            return;
        }

        const currentScreenEl = document.querySelector('.screen.active');
        const homeScreen = document.getElementById('homeScreen');

        if (currentScreenEl && currentScreenEl.id !== 'homeScreen') {
            this.animateScreenTransition(currentScreenEl.id, 'homeScreen');
        }

        this.currentScreen = 'home';
    }

    openApp(appName) {
        const appScreenId = appName + 'App';
        const appScreen = document.getElementById(appScreenId);

        if (!appScreen) {
            console.error(`App screen not found: ${appScreenId}`);
            return;
        }

        const currentScreenEl = document.querySelector('.screen.active');
        this.animateScreenTransition(currentScreenEl.id, appScreenId);
        this.currentScreen = appName;

        // Send app open event to FiveM
        this.sendNUICallback('rmf-phone:appOpened', { app: appName });
    }

    goToApp(appName) {
        this.openApp(appName);
    }

    animateScreenTransition(fromScreenId, toScreenId) {
        const fromScreen = document.getElementById(fromScreenId);
        const toScreen = document.getElementById(toScreenId);

        if (!fromScreen || !toScreen) return;

        // Remove active class from current screen
        fromScreen.classList.remove('active');
        fromScreen.classList.add('slide-left');

        // Show new screen
        toScreen.classList.add('active');
        toScreen.classList.add('app-transition-enter');

        // Clean up animation classes after transition
        setTimeout(() => {
            fromScreen.classList.remove('slide-left');
            toScreen.classList.remove('app-transition-enter');
        }, 300);
    }

    // Phone App Functions
    switchPhoneTab(tabName) {
        // Update tab buttons
        document.querySelectorAll('.phone-tabs .tab').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

        // Update tab content
        document.querySelectorAll('.tab-pane').forEach(pane => {
            pane.classList.remove('active');
        });
        document.getElementById(tabName).classList.add('active');
    }

    addToPhoneNumber(digit) {
        this.phoneNumber += digit;
        document.getElementById('phoneNumber').value = this.phoneNumber;
    }

    makeCall() {
        if (this.phoneNumber) {
            // Send call event to FiveM
            this.sendNUICallback('rmf-phone:makeCall', { number: this.phoneNumber });
            
            // Show call animation or feedback
            this.showCallFeedback(this.phoneNumber);
        }
    }

    callContact(number) {
        this.phoneNumber = number;
        document.getElementById('phoneNumber').value = this.phoneNumber;
        this.makeCall();
    }

    showCallFeedback(number) {
        // Simple feedback - could be enhanced with a call screen
        alert(`Calling ${number}...`);
        
        // Clear the number after call
        setTimeout(() => {
            this.phoneNumber = '';
            document.getElementById('phoneNumber').value = '';
        }, 2000);
    }

    // Messages App Functions
    openChat(chatId) {
        this.currentChat = chatId;
        
        // Update chat header
        const chatData = this.getChatData(chatId);
        document.getElementById('chatName').textContent = chatData.name;

        // Switch to chat screen
        this.animateScreenTransition('messagesApp', 'chatScreen');
        this.currentScreen = 'chat';

        // Load chat messages
        this.loadChatMessages(chatId);
    }

    getChatData(chatId) {
        const chatMap = {
            'john': { name: 'John Doe', status: 'Online' },
            'jane': { name: 'Jane Smith', status: 'Last seen 2 hours ago' },
            'group': { name: 'Group Chat', status: '3 members' }
        };
        return chatMap[chatId] || { name: 'Unknown', status: 'Offline' };
    }

    loadChatMessages(chatId) {
        // This would typically load from server
        // For now, we'll use the existing dummy messages
    }

    sendMessage() {
        const input = document.getElementById('messageInput');
        const message = input.value.trim();

        if (!message) return;

        // Add message to chat
        this.addMessageToChat(message, true);

        // Send to FiveM
        this.sendNUICallback('rmf-phone:sendMessage', {
            chat: this.currentChat,
            message: message
        });

        // Clear input
        input.value = '';

        // Simulate response (for demo)
        setTimeout(() => {
            this.addMessageToChat('Thanks for your message!', false);
        }, 1000);
    }

    addMessageToChat(message, sent) {
        const chatMessages = document.getElementById('chatMessages');
        const messageEl = document.createElement('div');
        messageEl.className = `message ${sent ? 'sent' : 'received'}`;

        const bubbleEl = document.createElement('div');
        bubbleEl.className = 'message-bubble';
        bubbleEl.textContent = message;

        const timeEl = document.createElement('div');
        timeEl.className = 'message-time';
        timeEl.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        messageEl.appendChild(bubbleEl);
        messageEl.appendChild(timeEl);
        chatMessages.appendChild(messageEl);

        // Scroll to bottom
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // Google App Functions
    performSearch() {
        const query = document.getElementById('searchInput').value.trim();
        if (!query) return;

        // Send search event to FiveM
        this.sendNUICallback('rmf-phone:search', { query: query });

        // Show dummy results
        this.showSearchResults(query);
    }

    showSearchResults(query) {
        const resultsContainer = document.getElementById('searchResults');
        resultsContainer.innerHTML = `
            <div class="search-item">
                <div class="search-title">Search results for "${query}"</div>
                <div class="search-description">Showing results for your search query</div>
            </div>
            <div class="search-item">
                <div class="search-title">${query} - Wikipedia</div>
                <div class="search-description">Learn more about ${query} on Wikipedia</div>
            </div>
            <div class="search-item">
                <div class="search-title">${query} - News</div>
                <div class="search-description">Latest news about ${query}</div>
            </div>
        `;
    }

    // Camera App Functions
    switchCameraMode(mode) {
        document.querySelectorAll('.camera-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`.camera-btn.${mode}`).classList.add('active');
    }

    capturePhoto() {
        // Send capture event to FiveM
        this.sendNUICallback('rmf-phone:capturePhoto', {});
        
        // Show capture feedback
        const btn = document.querySelector('.capture-btn');
        btn.style.transform = 'scale(0.8)';
        setTimeout(() => {
            btn.style.transform = 'scale(1)';
        }, 150);
    }

    // Control Center Functions
    toggleControlCenter() {
        const controlCenter = document.getElementById('controlCenter');
        this.controlCenterOpen = !this.controlCenterOpen;
        
        if (this.controlCenterOpen) {
            controlCenter.classList.add('show');
            this.closeNotifications();
        } else {
            controlCenter.classList.remove('show');
        }
    }

    closeControlCenter() {
        const controlCenter = document.getElementById('controlCenter');
        controlCenter.classList.remove('show');
        this.controlCenterOpen = false;
    }

    toggleControl(control) {
        // Send control toggle event to FiveM
        this.sendNUICallback('rmf-phone:toggleControl', { control: control });
    }

    setBrightness(value) {
        // Send brightness change event to FiveM
        this.sendNUICallback('rmf-phone:setBrightness', { value: parseInt(value) });
    }

    // Notifications Functions
    toggleNotifications() {
        const notificationsPanel = document.getElementById('notificationsPanel');
        this.notificationsOpen = !this.notificationsOpen;
        
        if (this.notificationsOpen) {
            notificationsPanel.classList.add('show');
            this.closeControlCenter();
        } else {
            notificationsPanel.classList.remove('show');
        }
    }

    closeNotifications() {
        const notificationsPanel = document.getElementById('notificationsPanel');
        notificationsPanel.classList.remove('show');
        this.notificationsOpen = false;
    }

    addNotification(notification) {
        const notificationsList = document.querySelector('.notifications-list');
        const notificationEl = document.createElement('div');
        notificationEl.className = 'notification-item';
        
        notificationEl.innerHTML = `
            <div class="notification-icon">${notification.icon || '📱'}</div>
            <div class="notification-content">
                <div class="notification-title">${notification.title}</div>
                <div class="notification-text">${notification.text}</div>
                <div class="notification-time">${notification.time || 'now'}</div>
            </div>
        `;
        
        notificationsList.insertBefore(notificationEl, notificationsList.firstChild);
    }

    // Time Functions
    updateTime() {
        const now = new Date();
        const timeString = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        document.getElementById('currentTime').textContent = timeString;
    }

    startTimeUpdate() {
        this.updateTime();
        setInterval(() => {
            this.updateTime();
        }, 1000);
    }

    // FiveM Integration
    sendNUICallback(event, data) {
        if (typeof window.invokeNative !== 'undefined') {
            // We're in FiveM
            fetch(`https://rmf-phone/${event}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            }).catch(console.error);
        } else {
            // We're in browser (for testing)
            console.log('NUI Callback:', event, data);
        }
    }

    // Phone control functions for FiveM
    showPhone() {
        const container = document.getElementById('phoneContainer');
        container.classList.add('show');
        document.body.style.cursor = 'auto';
    }

    closePhone() {
        const container = document.getElementById('phoneContainer');
        container.classList.remove('show');
        
        // Send close event to FiveM
        this.sendNUICallback('rmf-phone:close', {});
    }

    // Public API for FiveM callbacks
    receiveCall(data) {
        this.addNotification({
            icon: '📞',
            title: 'Incoming Call',
            text: `Call from ${data.number || 'Unknown'}`,
            time: 'now'
        });
    }

    receiveMessage(data) {
        this.addNotification({
            icon: '💬',
            title: data.sender || 'New Message',
            text: data.message || 'You have a new message',
            time: 'now'
        });

        // If chat is open, add message directly
        if (this.currentScreen === 'chat' && this.currentChat === data.chatId) {
            this.addMessageToChat(data.message, false);
        }
    }

    updateBattery(percentage) {
        const batteryLevel = document.querySelector('.battery-level');
        const batteryText = document.querySelector('.battery-percentage');
        
        batteryLevel.style.width = `${percentage}%`;
        batteryText.textContent = `${percentage}%`;
    }

    updateSignal(strength) {
        const signalBars = document.querySelectorAll('.signal-bar');
        signalBars.forEach((bar, index) => {
            bar.style.opacity = index < strength ? '1' : '0.3';
        });
    }
}

// Initialize the phone UI
let phoneUI;

document.addEventListener('DOMContentLoaded', () => {
    phoneUI = new RMFPhoneUI();
});

// FiveM Event Listeners
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch (data.type) {
        case 'rmf-phone:show':
            phoneUI.showPhone();
            break;
            
        case 'rmf-phone:hide':
            phoneUI.closePhone();
            break;
            
        case 'rmf-phone:receiveCall':
            phoneUI.receiveCall(data.data);
            break;
            
        case 'rmf-phone:receiveMessage':
            phoneUI.receiveMessage(data.data);
            break;
            
        case 'rmf-phone:updateBattery':
            phoneUI.updateBattery(data.data.percentage);
            break;
            
        case 'rmf-phone:updateSignal':
            phoneUI.updateSignal(data.data.strength);
            break;
            
        case 'rmf-phone:addNotification':
            phoneUI.addNotification(data.data);
            break;
    }
});

// Export for global access
window.RMFPhone = phoneUI;