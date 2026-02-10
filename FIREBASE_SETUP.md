# Firebase Setup Guide for Lab 2 Quiz

This guide will help you set up Firebase with **Google Sign-In** for the quiz leaderboard feature.

## Quick Setup (5-7 minutes)

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `sc2103-lab2-quiz` (or any name you prefer)
4. Disable Google Analytics (optional for this project)
5. Click **"Create project"**

### Step 2: Register Your Web App

1. In your Firebase project dashboard, click the **Web icon** (`</>`)
2. Enter app nickname: `Lab 2 Quiz`
3. **DO NOT** check "Firebase Hosting" (we're using local files)
4. Click **"Register app"**
5. **Copy the Firebase config** object that appears (looks like this):

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef123456"
};
```

### Step 3: Enable Google Authentication

1. Go to **"Build" → "Authentication"**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Click **"Google"**
5. **Enable** the toggle
6. Select a **Project support email** from the dropdown
7. Click **"Save"**

**Important**: Google Sign-In is now your only authentication method. Users must sign in with their Google account to save scores.

### Step 4: Enable Firestore Database

1. In Firebase Console, go to **"Build" → "Firestore Database"**
2. Click **"Create database"**
3. Select **"Start in production mode"** (we'll configure rules next)
4. Choose a Cloud Firestore location (pick one close to you)
5. Click **"Enable"**

### Step 5: Configure Security Rules

1. In Firestore Database, go to **"Rules"** tab
2. Replace the rules with this configuration:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to leaderboard
    match /artifacts/{appId}/public/data/leaderboard/{document=**} {
      allow read: if true;
      
      // Allow authenticated Google users to write scores
      allow create: if request.auth != null
                    && request.auth.token.email_verified == true
                    && request.resource.data.username is string
                    && request.resource.data.username.size() >= 2
                    && request.resource.data.username.size() <= 15
                    && request.resource.data.email is string
                    && request.resource.data.score is int
                    && request.resource.data.score >= 0
                    && request.resource.data.score <= request.resource.data.total
                    && request.resource.data.total is int
                    && request.resource.data.total <= 100
                    && request.resource.data.timestamp is int
                    && request.resource.data.userId == request.auth.uid;
      
      // Prevent updates and deletes
      allow update, delete: if false;
    }
  }
}
```

3. Click **"Publish"**

### Step 6: Configure Your Firebase Credentials

**Secure Method** - Your API keys stay private! 🔒

1. **Copy the template file**
   ```bash
   # Windows PowerShell
   Copy-Item firebase-config.template.js firebase-config.js
   ```

2. **Edit firebase-config.js**
   - Open `firebase-config.js` in a text editor
   - Replace the placeholder values with YOUR Firebase config from Step 2:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_ACTUAL_API_KEY",           // ← Paste yours here
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

const appId = "lab2-quiz-2026";  // ← Can customize this
```

3. **Save the file**
   - The `firebase-config.js` file is in `.gitignore`
   - Your credentials won't be committed to git! ✅

### Step 7: Test Your Setup

1. Open `index.html` in your browser
2. You should see a **"Sign in with Google"** button in the top right
3. Click it and sign in with your Google account
4. Complete a quiz and try submitting a score
5. Check the leaderboard to see if your score appears with your Google profile photo!

---

## How It Works

### Google Sign-In Flow

1. **User clicks "Sign in with Google"** → Google popup appears
2. **User authorizes the app** → Gets user's name, email, and photo
3. **Quiz completed** → Results screen shows personalized submit form
4. **Submit score** → Saved to Firestore with Google account info
5. **Leaderboard** → Shows user photos and names from Google accounts

### What's Stored

When you submit a score, we save:
- ✅ Display name (editable, defaults to your Google name)
- ✅ Email address (for identification)
- ✅ Profile photo URL (to show on leaderboard)
- ✅ Score and timestamp
- ✅ User ID (unique Google account identifier)

**Privacy**: Only users who sign in and submit scores have their data stored. Just browsing/practicing stores nothing.

---

## Troubleshooting

### "Sign-in failed" Error

**Cause**: Multiple possible issues with Google Authentication setup

**Diagnosis Steps**:
1. Open browser console (Press F12) and look for specific error codes
2. Common error codes and solutions:

**Error: `auth/unauthorized-domain`**
- **Fix**: Add your domain to authorized domains
- Go to Firebase Console → Authentication → Settings → Authorized domains
- Add `localhost` for local testing
- If hosting online, add your actual domain
- **NOTE**: Opening HTML file directly (file://) won't work - see below

**Error: `auth/popup-blocked`**
- **Fix**: Allow popups in your browser
- Click the popup icon in your browser's address bar
- Select "Always allow popups from this site"

**Error: `auth/operation-not-allowed`**
- **Fix**: Enable Google Sign-In in Firebase
- Go to Firebase Console → Authentication → Sign-in method
- Click "Google" and toggle it ON
- Save changes

**Error: `auth/invalid-api-key`**
- **Fix**: Check your `firebase-config.js` file
- Make sure `apiKey` matches exactly what's in Firebase Console
- No extra spaces or quotes

### Opening File Directly Won't Work

**Problem**: Double-clicking `index.html` opens `file:///C:/...` in browser

**Why**: Firebase Authentication requires HTTP/HTTPS protocol, not file://

**Solutions**:

**Option 1: Use VS Code Live Server (Recommended)**
```bash
# In VS Code:
1. Install "Live Server" extension
2. Right-click index.html
3. Select "Open with Live Server"
4. Opens as http://localhost:5500
```

**Option 2: Python Simple Server**
```bash
# In terminal (Windows PowerShell):
cd "C:\Users\harin\Downloads\SC2103"
python -m http.server 8000

# Open browser to: http://localhost:8000
```

**Option 3: Host Online**
- Upload to GitHub Pages, Netlify, or Firebase Hosting
- Add your actual domain to Firebase authorized domains

### Firebase Not Initialized

**Symptoms**: Console shows "Firebase not initialized" or firebaseConfig undefined

**Solutions**:
1. Verify `firebase-config.js` exists in the same folder as `index.html`
2. Check file contents - should have `const firebaseConfig = {...}`
3. Make sure the `<script src="firebase-config.js"></script>` line comes BEFORE the main Firebase imports
4. Try hard refresh: `Ctrl + Shift + R`

### Can't See "Sign in with Google" Button

**Cause**: Firebase not initialized or config file missing

**Solutions**:
1. Check that `firebase-config.js` exists (copy from `firebase-config.template.js`)
2. Verify your Firebase config in `firebase-config.js` has YOUR actual credentials
3. Hard refresh browser: `Ctrl + Shift + R` (Windows) or `Cmd + Shift + R` (Mac)
4. Check browser console (F12) for error messages

### "Permission denied" When Submitting Score

**Cause**: Google Sign-In not enabled or security rules incorrect

**Solutions**:
1. Go to Firebase Console → Authentication → Sign-in method
2. Make sure **Google** is enabled (toggle should be ON)
3. Verify security rules in Firestore → Rules tab
4. Check that rules include `request.auth.token.email_verified == true`
5. Make sure you're signed in (check top right corner of quiz)

### Google Sign-In Popup Closes Immediately

**Cause**: Browser popup blocker or authentication issue

**Solutions**:
1. Allow popups for your site in browser settings
2. Try a different browser (Chrome/Firefox recommended)
3. Check Firebase Console → Authentication → Settings
4. Verify your domain is in authorized domains list

### Scores Not Appearing on Leaderboard

**Cause**: Not signed in or database path mismatch

**Solutions**:
1. Make sure you sign in with Google before submitting
2. Open Firestore console and check: `artifacts` → `lab2-quiz-2026` → `public` → `data` → `leaderboard`
3. Verify documents are being created with email and photoURL fields
4. Check browser console for error messages

### Profile Photo Not Showing

**Cause**: Google account has no profile photo set

**Solutions**:
- This is normal if the Google account doesn't have a profile picture
- The leaderboard will just show the name without a photo
- Users can add a photo to their Google account to see it on the leaderboard

---

## Cost Considerations

Firebase Free Tier (Spark Plan) includes:
- ✅ 50,000 reads/day
- ✅ 20,000 writes/day
- ✅ 1 GB storage
- ✅ Anonymous authentication (unlimited)

**For this quiz app**: Even with 100 students taking multiple quizzes, you'll stay well within free limits.

---

## Optional: Deploy to Firebase Hosting

Want to share your quiz online?

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize hosting
firebase init hosting

# Select your project
# Set public directory to current folder
# Configure as single-page app: No
# Don't overwrite index.html

# Deploy
firebase deploy --only hosting
```

Your quiz will be available at: `https://your-project.firebaseapp.com`

---

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Console](https://console.firebase.google.com/)

---

**✨ That's it! Your quiz with leaderboard is now fully functional!**
